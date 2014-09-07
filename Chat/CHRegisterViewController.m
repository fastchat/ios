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

@interface CHRegisterViewController ()

@end

@implementation CHRegisterViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.title = @"Register";
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Register"];
}

- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    [self.usernameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    NSInteger tag = textField.tag;
    UITextField *next = (UITextField *)[self.view viewWithTag:++tag];
    if (next) {
        [next becomeFirstResponder];
        return NO;
    } else {
        [self createAccount:nil];
        return NO;
    }
}

- (IBAction)createAccount:(id)sender;
{
    if ([self canRegister]) {
#warning Not sure if this works
        CHUser *user = [CHUser userWithUsername:_usernameTextField.text password:_passwordTextField.text];
        user.registr.then(^{
            [self fulfill:user];
        });
    }
}

- (void)setRegisterButtonEnabled:(BOOL)enabled;
{
    self.registerButton.enabled = enabled;
}

- (IBAction)textfieldChanged:(UITextField *)sender;
{
    [self setRegisterButtonEnabled:[self canRegister]];
}

- (BOOL)canRegister;
{
    return _usernameTextField.text.length &&
    _passwordTextField.text.length &&
    _repeatPasswordTextField.text.length &&
    [_passwordTextField.text isEqualToString:_repeatPasswordTextField.text];
}


@end
