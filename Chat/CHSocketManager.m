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

//TODO: Refactor
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
{
    DLog("PACKET: %@", packet);
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
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
        
        /// Observers of the groups will pick up on the change
        
//        DLog(@"here");
//        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
//    
//        if( [self.delegate respondsToSelector:@selector(manager:doesCareAboutMessage:)]) {
//            if( ![self.delegate manager:self doesCareAboutMessage:message] ) {
//                // add messages to list and send notification
//                
//                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
//                
//                UIViewController *root = [[[[UIApplication sharedApplication] windows][0] rootViewController] childViewControllers][0];
//                
//                
//                [TSMessage showNotificationInViewController:root
//                                                      title:[NSString stringWithFormat:@"%@: %@", message.group.name, message.text]
//                                                   subtitle:nil
//                                                      image:nil
//                                                       type:TSMessageNotificationTypeMessage
//                                                   duration:3.0
//                                                   callback:^{
//                                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//                                                       CHMessageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
//                                                       vc.group = message.group;
//                                                       vc.groupId = message.groupId;
//                                                       
//                                                       [((UINavigationController*)root) popViewControllerAnimated:NO];
//                                                       [((UINavigationController*)root) pushViewController:vc animated:YES];
//                                                   }
//                                                buttonTitle:nil
//                                             buttonCallback:nil
//                                                 atPosition:TSMessageNotificationPositionTop
//                                       canBeDismissedByUser:YES];
//            }
//        }
    } else if ([packet.dataAsJSON[@"name"] isEqualToString:@"typing"]) {
//        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        //CHMessage *typer = [[CHMessage objectsFromJSON:@[data]] firstObject];
//        DLog(@"Someone is typing: %@", [[CHMessage objectsFromJSON:@[data]] firstObject]);
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
