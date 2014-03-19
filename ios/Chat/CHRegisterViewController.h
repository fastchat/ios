//
//  CHRegisterViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"

@interface CHRegisterViewController : UIViewController <UITextFieldDelegate, SocketIODelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end
