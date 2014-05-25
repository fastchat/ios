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
#import "CHGroupListTableViewController.h"
#import "CHUser.h"

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
    [[CHNetworkManager sharedManager] registerWithUsername:self.usernameTextField.text password:self.passwordTextField.text callback:^(NSArray *userData) {
        DLog(@"Registered user: %@",userData);

        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
