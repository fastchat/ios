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
#import "CHInviteUserViewController.h"
#import "CHUser.h"

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
    
    [_socket connectToHost:@"192.168.1.78" onPort:3888 withParams:@{@"token": [CHNetworkManager sharedManager].sessiontoken}];
    
    // Load previous messages

    /*[[CHNetworkManager sharedManager] getMessagesFromDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0] group:nil  callback:^(NSArray *messages) {
        DLog(@"Returned: %@", messages);
    }];*/
    self.messages = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.messageDisplayTextView setScrollsToTop:NO];
    
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(inviteUser)];
    self.navigationItem.rightBarButtonItem = inviteButton;
}

- (void) inviteUser;
{
    DLog(@"Displaying invite screen");
    CHInviteUserViewController *inviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHInviteUserViewController"];
    [self.navigationController pushViewController:inviteViewController animated:YES];
    
/*    [self addChildViewController:inviteViewController];
    inviteViewController.view.frame = self.view.frame;
    [self.view addSubview:inviteViewController.view];
    inviteViewController.view.alpha = 0;
    [inviteViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^
     {
         inviteViewController.view.alpha = 1;
     }
                     completion:nil];
 */
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

        [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];
    }

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
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    DLog(@"Curr user: %@", currUser);
    [_socket sendEvent:@"message" withData:@{@"from": currUser.username, @"text" : msg, @"groupId": @"532f9eea78fed3e206000001"}];

    self.messageTextField.text = @"";
    
    [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];

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