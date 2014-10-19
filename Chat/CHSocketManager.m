//
//  CHSocketManager.m
//  Chat
//
//  Created by Michael Caputo on 3/20/14.
//
//

#import "CHSocketManager.h"
#import "SocketIOPacket.h"
#import "CHNetworkManager.h"
#import "CHMessage.h"
#import "CHGroupListTableViewController.h"
#import "CHMessageViewController.h"
#import "CHAppDelegate.h"
#import "CHGroup.h"
#import "CHUser.h"
#import "CHConstants.h"

NSString *const kCHKeyData = @"data";
NSString *const kCHKeyType = @"type";
NSString *const kCHKeyAcknowledgement = @"ack";

NSString *const kCHPacketName = @"name";
NSString *const kCHPacketNameMessage = @"message";
NSString *const kCHPacketNameTyping = @"typing";
NSString *const kCHPacketNameNewGroup = @"new_group";
NSString *const kCHArgs = @"args";

@class SocketIO;

@interface CHSocketManager ()

@property (nonatomic, strong) SocketIO *socket;
@property (nonatomic, assign) BOOL disconnecting;
@property (nonatomic, assign, getter=isSending) BOOL sending;
@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation CHSocketManager

+ (CHSocketManager *)sharedManager;
{
    static CHSocketManager *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CHSocketManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.disconnecting = NO;
        self.sending = NO;
        self.queue = [NSMutableArray array];
        _progress = 0.0;
    }
    return self;
}

- (SocketIO *)getSocket;
{
    return _socket;
}

- (void)openSocket;
{
    self.disconnecting = NO;
    self.sending = NO;
    _progress = 0.0;
    [self.queue removeAllObjects];

    if( !_socket ) {
        _socket = [[SocketIO alloc] initWithDelegate:self];
    }
    
    if ([CHUser currentUser].sessionToken) {
        [_socket connectToHost:BASE_URL onPort:BASE_PORT withParams:@{@"token": [CHUser currentUser].sessionToken}];
    }
}

// Socket io stuff
- (void)socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error;
{
    DLog(@"Disconnected! %@ %@", socket, error);
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
{

}

- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
{

}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
{
    DLog("PACKET: %@", packet);
    if ([packet.dataAsJSON[kCHPacketName] isEqualToString:kCHPacketNameMessage]) {
        
        NSDictionary *data = [packet.dataAsJSON[kCHArgs] firstObject];
        CHMessage *message = [CHMessage objectFromJSON:data];
        message.group.lastMessage = message;
        if (![[CHUser currentUser] isEqual:message.getAuthorNonRecursive]) {
            [message.group unreadIncrement];
        }

        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            DLog(@"Socket IO Background Save Completed. Error? %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceivedNotification
                                                                object:self
                                                              userInfo:@{CHNotificationPayloadKey: message}];
        }];
        
    } else if ([packet.dataAsJSON[kCHPacketName] isEqualToString:kCHPacketNameTyping]) {
        NSDictionary *data = [packet.dataAsJSON[kCHArgs] firstObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTypingNotification
                                                            object:self
                                                          userInfo:@{CHNotificationPayloadKey: data}];
    } else if ([packet.dataAsJSON[kCHPacketName] isEqualToString:kCHPacketNameNewGroup]) {
        NSDictionary *data = [packet.dataAsJSON[kCHArgs] firstObject];
        CHGroup *group = [CHGroup objectFromJSON:data];
        DLog(@"Group: %@", group);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            DLog(@"Socket IO Background Save Completed. Error? %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewGroupNotification
                                                                object:self
                                                              userInfo:@{CHNotificationPayloadKey: group}];
        }];
        
    }
}

- (void)sendMessageWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;
{
    [self.queue addObject:@{kCHKeyData: data,
                            kCHKeyAcknowledgement: acknowledgement,
                            kCHKeyType: @"message"
                            }];
    [self send];
}

- (void)send;
{
    if (self.queue.count == 0) {
        if (self.disconnecting) [self closeSocket];
        return;
    }
    
    NSDictionary *payload = self.queue[0];
    [self.queue removeObjectAtIndex:0];
    
    [_socket sendEvent:payload[kCHKeyType] withData:payload[kCHKeyData] andAcknowledge:^(id argsData) {
        void (^ack)(id args) = payload[kCHKeyAcknowledgement];
        if (ack) {
            ack(argsData);
        }
        [self send];
    }];
}

- (void)sendTypingWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;
{
    [_socket sendEvent:@"typing" withData:data andAcknowledge:acknowledgement];
}

- (void)closeSocket;
{
    self.disconnecting = YES;
    if (self.queue.count == 0) {
        [_socket disconnect];
        _socket = nil;
        self.disconnecting = NO;
        _progress = 0.0;
    }
}

@end
