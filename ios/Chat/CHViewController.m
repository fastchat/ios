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
#import "CHNetworkManager.h"
#import "CHUser.h"
#import "CHSocketManager.h"

#define URL @"localhost" //localhost

@interface CHViewController ()

//@property (nonatomic, strong) SocketIO *socket;
@property (nonatomic, strong) UIView *view;

@end

@implementation CHViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.errorLabel.text = @"";
    DLog(@"Login controller");

}


#pragma mark - Socket IO

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
    

    [[CHNetworkManager sharedManager] postLoginWithUsername:self.emailTextField.text password:self.passwordTextField.text
        callback:^(bool successful, NSError *error) {
            if( successful ) {
                [[CHSocketManager sharedManager] openSocket];
                
                // Fire a notification that will be picked up by the groupList controller to refresh
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLogInSuccessful" object:nil];

                
                [self dismissViewControllerAnimated:YES completion:nil];

            }
            else {
                self.errorLabel.text = error.localizedDescription;
            }
        }];
    
    
    

}
@end
