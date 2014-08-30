//
//  CHInviteUserViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import <UIKit/UIKit.h>

@class CHGroup;

@interface CHInviteUserViewController : UIViewController

@property (strong, nonatomic) CHGroup *group;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

- (IBAction)sendInviteTouched:(id)sender;

@end
