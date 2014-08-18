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
#import "TSMessage.h"
#import "CHGroupListTableViewController.h"
#import "CHMessageViewController.h"
#import "CHAppDelegate.h"
#import "CHGroupsCollectionAccessor.h"
#import "CHGroup.h"
#import "CHUser.h"
#import <AudioToolbox/AudioToolbox.h>


@class SocketIO;


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

- (SocketIO *)getSocket;
{
    return _socket;
}

-(void)openSocket;
{
    if( !_socket ) {
        _socket = [[SocketIO alloc] initWithDelegate:self];
    }
    if( [[CHNetworkManager sharedManager] hasStoredSessionToken]) {
        [_socket connectToHost:@"powerful-cliffs-9562.herokuapp.com" onPort:80 withParams:@{@"token": [CHUser currentUser].sessionToken}];
    }
}

// Socket io stuff
- (void) socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error;
{
    DLog(@"Disconnected! %@ %@", socket, error);
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
{

}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
{

}

// THIS NEEDS TO BE REFACTORED
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
{
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        
        
        
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        CHMessage *message = [[CHMessage objectsFromJSON:@[data]] firstObject];
        DLog(@"here");
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
        CHGroup *group = [[CHGroupsCollectionAccessor sharedAccessor] getGroupWithId:message.group];
        [group setUnread:[NSNumber numberWithInteger:[group.unread intValue] + 1]];
        DLog(@"Unread: %@", group.unread);
        
       
        
        if( [self.delegate respondsToSelector:@selector(manager:doesCareAboutMessage:)]) {
            if( ![self.delegate manager:self doesCareAboutMessage:message] ) {
                // add messages to list and send notification
                
                AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
                
                UIViewController *root = [[[[UIApplication sharedApplication] windows][0] rootViewController] childViewControllers][0];
               

              [TSMessage showNotificationInViewController:root
                                                    title:[NSString stringWithFormat:@"%@: %@", [[CHGroupsCollectionAccessor sharedAccessor] getGroupWithId:message.group].name, message.text]
                                                 subtitle:nil image:nil type:TSMessageNotificationTypeMessage duration:3.0
                                                 callback:^{
                                                     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                                                     CHMessageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
                                                     [vc setGroup:[[CHGroupsCollectionAccessor sharedAccessor] getGroupWithId:message.group]];
                                                     [vc setGroupId:message.group];
                                                     
                                                     [((UINavigationController*)root) popViewControllerAnimated:NO];
                                                     [((UINavigationController*)root) pushViewController:vc animated:YES];

                                                 }
                                              buttonTitle:nil buttonCallback:nil
                                               atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
            
            }
            
        }
    }
    
}

-(void) sendMessageWithEvent: (NSString *)message data: (NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;
{
    [_socket sendEvent:message withData:data andAcknowledge:acknowledgement];
}

-(void) closeSocket;
{
    [_socket disconnect];
    _socket = nil;
}

@end
