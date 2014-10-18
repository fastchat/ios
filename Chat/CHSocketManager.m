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
    }
    return self;
}

- (SocketIO *)getSocket;
{
    return _socket;
}

-(void)openSocket;
{
    self.disconnecting = NO;
    self.sending = NO;

    if( !_socket ) {
        _socket = [[SocketIO alloc] initWithDelegate:self];
    }
    
    if ([CHUser currentUser].sessionToken) {
        [_socket connectToHost:BASE_URL onPort:BASE_PORT withParams:@{@"token": [CHUser currentUser].sessionToken}];
    }
    DLog(@"Open Socket End");
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

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
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
    self.sending = YES;
    [_socket sendEvent:@"message" withData:data andAcknowledge:^(id argsData) {
        self.sending = NO;
        if (acknowledgement) {
            acknowledgement(argsData);
        }
        if (self.disconnecting) {
            [self closeSocket];
        }
    }];
}

- (void)sendTypingWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;
{
    [_socket sendEvent:@"typing" withData:data andAcknowledge:acknowledgement];
}

- (void)closeSocket;
{
    if (!self.isSending) {
        [_socket disconnect];
        _socket = nil;
    } else {
        self.disconnecting = YES;
    }
    
}

@end
