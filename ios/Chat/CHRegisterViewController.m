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
        [[CHNetworkManager sharedManager] registerWithUsername:self.usernameTextField.text password:self.passwordTextField.text callback:^(NSArray *userData) {
            DLog(@"Registered user: %@", userData);
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
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
