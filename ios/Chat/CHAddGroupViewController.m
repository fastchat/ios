//
//  CHAddGroupViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHAddGroupViewController.h"
#import "CHNetworkManager.h"
#include "CHAppDelegate.h"

@interface CHAddGroupViewController ()

@end

@implementation CHAddGroupViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.title = @"Create Group";
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(createGroup)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.groupNameTextField setPlaceholder:@"Group name (optional)"];
}


- (void)createGroup;
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
        [[CHNetworkManager sharedManager] createGroupWithName:self.groupNameTextField.text members:members callback:^(bool successful, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}


@end
