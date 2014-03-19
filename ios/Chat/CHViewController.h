//
//  CHViewController.h
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"

@interface CHViewController : UIViewController <SocketIODelegate>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)registerWasTouched:(id)sender;
- (IBAction)loginWasTouched:(id)sender;

@end
