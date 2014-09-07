//
//  CHInviteUserViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import "CHInviteUserViewController.h"
#import "CHNetworkManager.h"
#import "CHGroup.h"

@interface CHInviteUserViewController ()

@end

@implementation CHInviteUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Invite User"];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelWasTouched)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)cancelWasTouched;
{
    [self fulfill:nil];
}


- (IBAction)sendInviteTouched:(id)sender;
{
    if (self.usernameTextField.text.length > 0) {
        NSArray *invitees = @[self.usernameTextField.text];
        
        [self.group addUsers:invitees].then(^{
            [self fulfill:nil];
        });
    }
}

@end
