//
//  CHViewController.m
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import "CHLoginViewController.h"
#import "SocketIOPacket.h"
#import "AFNetworking.h"
#import "CHRegisterViewController.h"
#import "CHGroupListTableViewController.h"
#import "CHNetworkManager.h"
#import "CHUser.h"
#import "CHSocketManager.h"

#define URL @"localhost" //localhost

@interface CHLoginViewController ()

@property (nonatomic, strong) UIView *view;

@end

@implementation CHLoginViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.title = @"Login";
    self.errorLabel.text = @"";

    [self updateTextFieldLooks:@[_emailTextField, _passwordTextField]];
}

- (void)updateTextFieldLooks:(NSArray *)textfields;
{
    for (UITextField *field in textfields) {
        field.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        field.layer.borderWidth = 0.5;
        field.backgroundColor = [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
        field.layer.cornerRadius = 3.0;
        field.layer.masksToBounds = YES;
    }
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    [self.emailTextField becomeFirstResponder];
}


- (IBAction)registerWasTouched:(id)sender {
    CHRegisterViewController *registerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHRegisterViewController"];

    [self presentViewController:registerViewController animated:YES completion:nil];
}

#pragma mark - Login

- (IBAction)loginWasTouched:(id)sender {
    self.errorLabel.text = @"";
    
    [[CHNetworkManager sharedManager] postLoginWithUsername:self.emailTextField.text password:self.passwordTextField.text
        callback:^(bool successful, NSError *error) {
            if( successful ) {
                [[CHSocketManager sharedManager] openSocket];
                
                // Fire a notification that will be picked up by the groupList controller to refresh
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadGroupListTable" object:nil];

                CHUser *loggedInAs = [[CHNetworkManager sharedManager] currentUser];
                
                [[CHNetworkManager sharedManager] getAvatarOfUser:loggedInAs.userId callback:^(UIImage *avatar) {
                    [[CHNetworkManager sharedManager] currentUser].avatar = avatar;
                }];
                
                [self dismissViewControllerAnimated:YES completion:nil];

            }
            else {
                self.errorLabel.text = error.localizedDescription;
            }
        }];
}

@end
