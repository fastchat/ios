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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelWasTouched)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)cancelWasTouched;
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)sendInviteTouched:(id)sender;
{
    NSArray *invitees = @[self.usernameTextField.text];
    
    [[CHNetworkManager sharedManager] addNewUsers:invitees groupId:self.groupId callback:^(bool successful, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];

}
@end
