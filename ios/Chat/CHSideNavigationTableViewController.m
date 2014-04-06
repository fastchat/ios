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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.menuLabels = @[@"Profile", @"Invitations", @"Sign Out"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.menuLabels[indexPath.row];
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 1 ) {
        DLog(@"Navigate to invitations screen.");
        CHInvitationsTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHInvitationsTableViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    // Logout
    else if( indexPath.row == 2 ) {
        [[CHNetworkManager sharedManager] logoutWithCallback:^(bool successful, NSError *error) {
            //[self.navigationController popViewControllerAnimated:YES];
            [[CHSocketManager sharedManager] closeSocket];
            [self.navigationController popViewControllerAnimated:YES];
            //[self presentViewController:loginController animated:NO completion:nil];
            CHViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewController"];
            [self presentViewController:loginController animated:NO completion:nil];
        }];
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end