//
//  CHMessageViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHMessageViewController.h"
#import "CHNetworkManager.h"

@interface CHMessageViewController ()
    @property NSString *messages;

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
    
    // Load previous messages

    /*[[CHNetworkManager sharedManager] getMessagesFromDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0] group:nil  callback:^(NSArray *messages) {
        DLog(@"Returned: %@", messages);
    }];*/
    self.messages = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
