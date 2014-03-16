//
//  CHViewController.m
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import "CHViewController.h"
#import "SocketIOPacket.h"

@interface CHViewController ()

@property (nonatomic, strong) SocketIO *socket;

@end

@implementation CHViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    ///
    /// Connect to server!
    ///
    self.socket = [[SocketIO alloc] initWithDelegate:self];
//    [_socket connectToHost:@"localhost" onPort:3000]; //localhost
    
    //try this
    [_socket connectToHost:@"localhost" onPort:3000 withParams:@{@"token": @"1394940167580_nF5N1JSSSVqYFGif"}];
}


#pragma mark - Socket IO

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
    DLog(@"Event: %@", packet.data);
}


@end
