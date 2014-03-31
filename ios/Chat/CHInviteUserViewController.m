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


- (IBAction)sendInviteTouched:(id)sender {
    DLog(@"Sending invite");

    NSArray *invitees = @[self.usernameTextField.text];
    
    [[CHNetworkManager sharedManager] sendInviteToUsers:invitees groupId:self.groupId callback:^(bool successful, NSError *error) {
        DLog(@"Inviting finished!");
        [self.navigationController popViewControllerAnimated:YES];
    }];

}
@end
