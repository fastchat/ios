//
//  CHInviteUserViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import "CHInviteUserViewController.h"
#import "CHNetworkManager.h"

@interface CHInviteUserViewController ()

@end

@implementation CHInviteUserViewController

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
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelWasTouched)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)cancelWasTouched;
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)sendInviteTouched:(id)sender {
    DLog(@"Sending invite");

    NSArray *invitees = @[self.usernameTextField.text];
    
    [[CHNetworkManager sharedManager] addNewUsers:invitees groupId:self.groupId callback:^(bool successful, NSError *error) {
        DLog(@"Inviting finished!");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];

}
@end
