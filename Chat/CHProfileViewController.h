//
//  CHProfileViewController.h
//  Chat
//
//  Created by Michael Caputo on 4/10/14.
//
//

#import <UIKit/UIKit.h>
#import "DBCameraContainerViewController.h"
#import "CHDynamicSwitchCell.h"

@interface CHProfileViewController : UITableViewController <
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    DBCameraViewControllerDelegate,
    CHDynamicSwitchDelegate
>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (IBAction)cameraButtonTouched:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)logoutFromAll:(id)sender;

@end
