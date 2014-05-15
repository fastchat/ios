//
//  CHSideNavigationTableViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/20/14.
//
//

#import "CHSideNavigationTableViewController.h"
#import "CHInvitationsTableViewController.h"
#import "CHNetworkManager.h"
#import "CHViewController.h"
#import "CHSocketManager.h"
#import "CHGroupListTableViewController.h"
#import "CHProfileViewController.h"

@interface CHSideNavigationTableViewController ()
@property NSArray *menuLabels;
@end

@implementation CHSideNavigationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuLabels = @[@"Profile", @"Sign Out"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.menuLabels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.menuLabels[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 0 ) {
        CHProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHProfileViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    // Logout
    else if( indexPath.row == 1 ) {
        [[CHNetworkManager sharedManager] logoutWithCallback:^(bool successful, NSError *error) {
            [[CHSocketManager sharedManager] closeSocket];
            [self.navigationController popViewControllerAnimated:YES];
            CHViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewController"];
            [self presentViewController:loginController animated:NO completion:nil];

        }];
        
    }
}

@end
