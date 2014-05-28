//
//  CHViewController.h
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import <UIKit/UIKit.h>

@interface CHLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginWasTouched:(id)sender;
- (IBAction)textfieldChanged:(UITextField *)sender;

@end
