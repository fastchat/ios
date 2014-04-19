//
//  CHProfileViewController.h
//  Chat
//
//  Created by Michael Caputo on 4/10/14.
//
//

#import <UIKit/UIKit.h>

@interface CHProfileViewController : UIViewController <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *avatarCameraButton;
- (IBAction)cameraButtonTouched:(id)sender;


@end
