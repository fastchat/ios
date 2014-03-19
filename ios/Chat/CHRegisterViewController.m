//
//  CHRegisterViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHRegisterViewController.h"
#import "SocketIOPacket.h"
#import "AFNetworking.h"
#import "CHNetworkManager.h"

#define URL @"localhost" //localhost

@interface CHRegisterViewController ()

@property (nonatomic, strong) SocketIO *socket;

@end

@implementation CHRegisterViewController

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
    
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishRegistration)];
    self.navigationItem.rightBarButtonItem = finishButton;
}

-(void)finishRegistration {
    DLog(@"Attempting to register user %@ with password %@ and email %@", self.usernameTextField.text, self.passwordTextField.text, self.emailTextField.text);
    
    [[CHNetworkManager sharedManager] registerWithEmail:self.emailTextField.text password:self.passwordTextField.text callback:^(NSArray *userData) {
        DLog(@"Registered user: %@",userData);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
   /* self.socket = [[SocketIO alloc] initWithDelegate:self];
    //    [_socket connectToHost:@"localhost" onPort:3000]; //localhost
    
    
    NSDictionary *params = @{@"email": self.emailTextField.text,
                             @"password": self.passwordTextField.text};
    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"http://%@:3000/register", URL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSON: %@", responseObject);
        [_socket connectToHost:URL onPort:3000 withParams:@{@"token": responseObject[@"session-token"]}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
    }];
    */
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

@end
