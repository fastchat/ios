//
//  CHMessageViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHMessageViewController.h"
#import "CHNetworkManager.h"
#import "SocketIOPacket.h"
#import "CHNetworkManager.h"

@interface CHMessageViewController ()
    @property NSString *messages;
    @property (nonatomic, strong) SocketIO *socket;
@end

@implementation CHMessageViewController
    IBOutlet NSLayoutConstraint* _textViewSpaceToBottomConstraint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ///
    /// Connect to server!
    ///
    self.socket = [[SocketIO alloc] initWithDelegate:self];
    
    [_socket connectToHost:@"129.21.120.30" onPort:3000 withParams:@{@"token": [CHNetworkManager sharedManager].sessiontoken}];
    
    // Load previous messages

    /*[[CHNetworkManager sharedManager] getMessagesFromDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0] group:nil  callback:^(NSArray *messages) {
        DLog(@"Returned: %@", messages);
    }];*/
    self.messages = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.messageDisplayTextView setScrollsToTop:NO];
}

- (void) socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
    NSString *text = self.messageDisplayTextView.text;
    text = [text stringByAppendingString:@"\nConnected\n"];
    self.messageDisplayTextView.text = text;
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
        
            self.messageDisplayTextView.text = [NSString stringWithFormat:@"%@ %@\n%@: %@\n\n", self.messageDisplayTextView.text, [[NSDate alloc] initWithTimeIntervalSinceNow:0], data[@"from"], data[@"text"]];
        
    }
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //    DLog(@"DISPATCHING");
    //    [_socket sendEvent:@"message" withData:@{@"from": @"Ethan", @"text" : @"ping", @"groupId": @"5328d87af8d3d3af7b000003"}];
    //});
    
//    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
/*        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
    if( data != nil ) {
        DLog(@"data: %@", data);
        NSString *show = [NSString stringWithFormat:@"%@: %@\n", data[@"from"], data[@"text"]];
        
        NSString *text = self.messageDisplayTextView.text;
        text = [text stringByAppendingString:show];
        self.messageDisplayTextView.text = text;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"DISPATCHING");
            [_socket sendEvent:@"message" withData:@{@"from": @"Ethan", @"text" : @"ping", @"groupId": @"5328d87af8d3d3af7b000003"}];
        });
    }*/
  //  } else {
/*        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"DISPATCHING");
            [_socket sendEvent:@"message" withData:@{@"from": @"simulator", @"text" : self.messageTextField.text, @"groupId": @"5328d87af8d3d3af7b000003"}];
        });
    }
*/
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendButtonTouched:(id)sender {
    DLog(@"Sending message: %@",self.messageTextField.text);
    //self.messages = [self.messages stringByAppendingString:self.messageTextField.text];
    self.messageDisplayTextView.text = [NSString stringWithFormat:@"%@ %@\n%@\n\n", self.messageDisplayTextView.text, [[NSDate alloc] initWithTimeIntervalSinceNow:0], self.messageTextField.text];
    //self.messageTextField.text = @"";
    NSString *msg = self.messageTextField.text;
    [_socket sendEvent:@"message" withData:@{@"from": @"Test", @"text" : msg, @"groupId": @"5328d87af8d3d3af7b000003"}];

    self.messageTextField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) keyboardWillShow: (NSNotification*) n
{
    NSValue* bv = n.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect br = [bv CGRectValue];
    
    _textViewSpaceToBottomConstraint.constant = br.size.height;
}

- (void) keyboardWillHide: (NSNotification*) n
{
    _textViewSpaceToBottomConstraint.constant = 0;
}

@end
