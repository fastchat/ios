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
        CHMessage *message = [[CHMessage objectsFromJSON:@[data]] firstObject];
        
        if( [self.delegate respondsToSelector:@selector(manager:doesCareAboutMessage:)]) {
            if( ![self.delegate manager:self doesCareAboutMessage:message] ) {
                // add messages to list
            }
            
            
        }
    }
    
}

-(void) sendMessageWithEvent: (NSString *)message data: (NSDictionary *)data;
{
    DLog(@"Sending message: %@", _socket);
    [_socket sendEvent:message withData: data];
}

-(void) closeSocket;
{
    [_socket disconnect];
    _socket = nil;
}

@end
