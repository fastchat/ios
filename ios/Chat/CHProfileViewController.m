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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    self.title = @"Profile";
    self.userNameLabel.text = currUser.username;
    
   self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if( !currUser.avatar ) {
        [[CHNetworkManager sharedManager] getAvatarOfUser:currUser.userId callback:^(UIImage *avatar) {
            [self.avatarImageView setImage:avatar];
        }];
    }
    /*else {
        DLog(@"Setting the avatar found for user %@", currUser.username);
        [self.avatarImageView setImage:currUser.avatar];
    }*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    
    if( currUser.avatar == nil ) {
        [[CHNetworkManager sharedManager] getAvatarOfUser:currUser.userId callback:^(UIImage *avatar) {
            DLog(@"Called avatar of %@ and got %@", currUser.username, avatar);
            if( avatar == nil ) {
                [self.avatarImageView setImage:[UIImage imageWithContentsOfFile:@"profile-dark.png"]];
            }
            else {
                [self.avatarImageView setImage:avatar];
            }
        }];
    }
    else {
        DLog(@"For user %@ we found avatar %@", currUser.username, currUser.avatar);
        [self.avatarImageView setImage:currUser.avatar];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    // Ensure size is less than 200KB
    NSData *imgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation((image), 0.5)];
    int imageSize   = imgData.length;
    NSLog(@"size of image in KB: %f ", imageSize/1024.0);
    
    if( imageSize/1024.0 <= 200 ) {
    

        [[CHNetworkManager sharedManager] pushNewAvatarForUser:[[CHNetworkManager sharedManager] currentUser].userId avatarImage:image callback:^(bool successful, NSError *error) {

            if( successful ) {
                DLog(@"Successfully changed");
                [self.avatarImageView setImage:image];
            }
            else {
                DLog(@"Someething went wrong: %@", error);
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

- (IBAction)cameraButtonTouched:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:^{}];
}
@end
