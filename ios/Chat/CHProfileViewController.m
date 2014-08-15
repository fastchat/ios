//
//  CHProfileViewController.m
//  Chat
//
//  Created by Michael Caputo on 4/10/14.
//
//

#import "CHProfileViewController.h"
#import "CHNetworkManager.h"
#import "CHUser.h"

@interface CHProfileViewController ()

@property (weak, nonatomic) UIButton *cameraButton;
@end

@implementation CHProfileViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    self.title = @"Profile";
    self.userNameLabel.text = currUser.username;
    
   self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    DLog(@"Curr User: %@", currUser);
    
    if( currUser.avatar == nil ) {
        [[CHNetworkManager sharedManager] getAvatarOfUser:currUser.chID callback:^(UIImage *avatar) {
            if( avatar == nil ) {
                [self.avatarImageView setImage:[UIImage imageWithContentsOfFile:@"profile-dark.png"]];
            }
            else {
                [self.avatarImageView setImage:avatar];
            }
        }];
    }
    else {
        [self.avatarImageView setImage:currUser.avatar];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    // Ensure size is less than 200KB
    NSData *imgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation((image), 0.5)];
    unsigned long imageSize = imgData.length;
    
    if( imageSize/1024.0 <= 200 ) {

        [[CHNetworkManager sharedManager] pushNewAvatarForUser:[[CHNetworkManager sharedManager] currentUser].chID avatarImage:image callback:^(bool successful, NSError *error) {

            if( successful ) {
                [self.avatarImageView setImage:image];
            }
            else {
                DLog(@"Something went wrong: %@", error);
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Size error"
                                                        message:@"Could not use selected image. Please ensure image is less than 200KB for testing purposes."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)cameraButtonTouched:(id)sender;
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}
@end
