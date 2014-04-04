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

@class SocketIO;

@implementation CHSocketManager

+ (CHSocketManager *)sharedManager;
{
    static CHSocketManager *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DLog(@"Creating socket manager");
        _sharedManager = [[CHSocketManager alloc] init];
    });
    
    return _sharedManager;
}

-(SocketIO *)getSocket;
{

    return _socket;
}

-(void)openSocket;
{
    if( !_socket ) {
        _socket = [[SocketIO alloc] initWithDelegate:self];
    }
    if( [[CHNetworkManager sharedManager] hasStoredSessionToken]) {
        [_socket connectToHost:@"powerful-cliffs-9562.herokuapp.com" onPort:80 withParams:@{@"token": [CHNetworkManager sharedManager].sessiontoken}];
    }
    DLog(@"CONNECTED!");
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
    DLog(@"Messsage: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
{
    DLog(@"JSON: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
{
    DLog(@"IN THIS EVENT RECEIVE");
    DLog(@"Event: %@", packet.dataAsJSON);
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        
        if( [self.delegate respondsToSelector:@selector(manager:doesCareAboutMessage:)]) {
            if( ![self.delegate manager:self doesCareAboutMessage:data] ) {
                // add messages to list
            }
            
            
        }
        //            self.messageDisplayTextView.text = [NSString stringWithFormat:@"%@ %@\n%@: %@\n\n", self.messageDisplayTextView.text, [[NSDate alloc] initWithTimeIntervalSinceNow:0], data[@"from"], data[@"text"]];
        
        // Ensure only messages from the current group are used
        //        if (self.groupId isEqualToString:packet.dataAsJSON[@"groupId"]) {
        //[self.messageArray addObject:data[@"text"]];
        //  [_messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
        //[self.messageAuthorsArray addObject:data[@"from"]];
        
        //        [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];
        //[self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
        //[self.messageTable reloadData];
    }
    
}

-(void) sendMessageWithEvent: (NSString *)message data: (NSDictionary *)data;
{
    DLog(@"Sending message: %@", _socket);
    [_socket sendEvent:message withData: data];
//    [_socket sendEvent:@"message" withData:@{@"from": currUser.userId, @"text" : msg, @"groupId": self.groupId}];
}

-(void) closeSocket;
{
    [_socket disconnect];
    _socket = nil;
}

@end
