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
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
//    [self.emailTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    NSInteger tag = textField.tag;
    UITextField *next = (UITextField *)[self.view viewWithTag:++tag];
    if (next) {
        [next becomeFirstResponder];
        return NO;
    } else {
        [self loginWasTouched:nil];
        return NO;
    }
}

#pragma mark - Login

- (IBAction)loginWasTouched:(id)sender;
{
    if (![self canLogin]) {
        return;
    }
    
    self.errorLabel.text = @"";
    
    CHUser *user = [CHUser userWithUsername:self.emailTextField.text password:self.passwordTextField.text];
    user.login.then(^(CHUser *user){
        
    });
    
//    [[CHNetworkManager sharedManager] postLoginWithUsername:self.emailTextField.text password:self.passwordTextField.text
//        callback:^(bool successful, NSError *error) {
//            if( successful ) {
//                [[CHSocketManager sharedManager] openSocket];
//                
//                // Fire a notification that will be picked up by the groupList controller to refresh
//                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
//
//                CHUser *loggedInAs = [[CHNetworkManager sharedManager] currentUser];
//                
//                [[CHNetworkManager sharedManager] getAvatarOfUser:loggedInAs.chID callback:^(UIImage *avatar) {
//                    [[CHNetworkManager sharedManager] currentUser].avatar = avatar;
//                }];
//                
//                [self dismissViewControllerAnimated:YES completion:nil];
//
//            }
//            else {
//                self.errorLabel.text = error.localizedDescription;
//            }
//        }];
}

- (IBAction)textfieldChanged:(UITextField *)sender;
{
    [self enableLoginButton:[self canLogin]];
}

- (void)enableLoginButton:(BOOL)enabled;
{
    self.loginButton.enabled = enabled;
}

- (BOOL)canLogin;
{
    return _emailTextField.text.length && _passwordTextField.text.length;
}

@end
