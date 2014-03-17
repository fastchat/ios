//
//  CHViewController.m
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import "CHViewController.h"
#import "SocketIOPacket.h"
#import "AFNetworking.h"

#define URL @"129.21.40.209" //localhost

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
    
    
    NSDictionary *params = @{@"email": @"3ethanmski@gmail.com",
                             @"password": @"test"};
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"http://%@:3000/login", URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSON: %@", responseObject);
        [_socket connectToHost:URL onPort:3000 withParams:@{@"token": responseObject[@"session-token"]}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
    }];
    
}


#pragma mark - Socket IO

- (void) socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
    NSString *text = self.textView.text;
    text = [text stringByAppendingString:@"\nConnected\n"];
    self.textView.text = text;
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
    DLog(@"Event: %@", packet.dataAsJSON);
    
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        NSString *show = [NSString stringWithFormat:@"%@: %@\n", data[@"from"], data[@"text"]];
        
        NSString *text = self.textView.text;
        text = [text stringByAppendingString:show];
        self.textView.text = text;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"DISPATCHING");
            [_socket sendEvent:@"message" withData:@{@"from": @"Ethan", @"text" : @"ping", @"groupId": @"5325e046c68db1c326000001"}];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"DISPATCHING");
            [_socket sendEvent:@"message" withData:@{@"from": @"Ethan", @"text" : @"ping", @"groupId": @"5325e046c68db1c326000001"}];
        });
    }
    
}


@end
