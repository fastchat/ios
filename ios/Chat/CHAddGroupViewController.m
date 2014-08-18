//
//  CHAddGroupViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHAddGroupViewController.h"
#import "CHGroup.h"

@interface CHAddGroupViewController ()

@end

@implementation CHAddGroupViewController


- (IBAction)saveGroup:(id)sender;
{
    NSMutableArray *members = [[NSMutableArray alloc] init];
    if (![self.firstMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.firstMemberTextField.text];
    }
    if (![self.secondMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.secondMemberTextField.text];
    }
    if (![self.thirdMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.thirdMemberTextField.text];
    }
    
    if( members.count >= 1 ) {
        [CHGroup groupWithName:self.groupNameTextField.text members:members].then(^(CHGroup *group){
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

@end
