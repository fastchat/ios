//
//  CHViewController.m
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import "CHLoginViewController.h"
#import "CHRegisterViewController.h"
#import "CHGroupListTableViewController.h"
#import "CHSocketManager.h"
#import "CHUser.h"

@interface CHLoginViewController ()

@property (nonatomic, strong) UIView *view;

@end

@implementation CHLoginViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    self.title = @"Login";
    self.errorLabel.text = @"";
    
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Login"];
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
//    [self.emailTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [self.emailTextField becomeFirstResponder];
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
        [[CHSocketManager sharedManager] openSocket];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
        
        [self fulfill:user];
    }).catch(^(NSError *error){
        self.errorLabel.text = error.localizedDescription;
    });
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
