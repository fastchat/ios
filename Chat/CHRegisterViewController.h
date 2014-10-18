//
//  CHRegisterViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@interface CHRegisterViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, copy) void (^onRegister)(id object);
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)createAccount:(id)sender;
- (IBAction)textfieldChanged:(UITextField *)sender;

@end
