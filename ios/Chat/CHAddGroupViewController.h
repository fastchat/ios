//
//  CHAddGroupViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@interface CHAddGroupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

@property (strong, nonatomic) IBOutlet UIImageView *screenShotImageView;
@property (strong, nonatomic) UIImage *screenShotImage;

@end
