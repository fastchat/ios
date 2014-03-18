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
#import "CHRegisterViewController.h"
#import "CHGroupListTableViewController.h"

#define URL @"localhost" //localhost

@interface CHViewController ()

@property (nonatomic, strong) SocketIO *socket;

@end

@implementation CHViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.errorLabel.text = @"";
    
    ///
    /// Connect to server!
    ///
    self.socket = [[SocketIO alloc] initWithDelegate:self];
//    [_socket connectToHost:@"localhost" onPort:3000]; //localhost
    
    
//    NSDictionary *params = @{@"email": @"3ethanmski@gmail.com",
//                             @"password": @"test"};
    
/*    NSDictionary *params = @{@"email": @"test@test.com",
                             @"password": @"test"};
*/
/*    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"http://%@:3000/login", URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSON: %@", responseObject);
        [_socket connectToHost:URL onPort:3000 withParams:@{@"token": responseObject[@"session-token"]}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
    }];
*/
}


#pragma mark - Socket IO
/*
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
*/

- (IBAction)registerWasTouched:(id)sender {
    DLog(@"Register new user");
    CHRegisterViewController *registerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHRegisterViewController"];
    DLog(@"navigationController: %@",self.navigationController);

    [[self navigationController] pushViewController:registerViewController animated:YES];

}

- (IBAction)loginWasTouched:(id)sender {
    self.errorLabel.text = @"";
    DLog(@"Attempting to login with user %@ and password %@", self.emailTextField.text, self.passwordTextField.text);
    NSDictionary *params = @{@"email": self.emailTextField.text,
     @"password": self.passwordTextField.text};
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"http://%@:3000/login", URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DLog(@"JSON: %@", responseObject);
        
            [_socket connectToHost:URL onPort:3000 withParams:@{@"token": responseObject[@"session-token"]}];
            CHGroupListTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHGroupListTableViewController"];
            [[self navigationController] pushViewController:vc animated:YES];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DLog(@"Error: %@", error);
         //DLog(@"responseObject message: %@",responseObject.error);
         self.errorLabel.text = error.localizedDescription;//@"Oops! Something went wrong!";
     }];
}
@end
