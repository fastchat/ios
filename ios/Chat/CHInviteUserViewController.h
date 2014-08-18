//
//  CHInviteUserViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import <UIKit/UIKit.h>

@interface CHInviteUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) NSString *groupId;

- (IBAction)sendInviteTouched:(id)sender;

@end
