//
//  CHGroupListTableViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHGroupListTableViewController.h"
#import "CHNetworkManager.h"
#import "CHAddGroupViewController.h"
#import "CHAppDelegate.h"
#import "CHSideNavigationTableViewController.h"
#import "CHMessageViewController.h"
#import "CHLoginViewController.h"
#import "CHMessageTableViewController.h"
#import "CHGroup.h"
#import "CHUser.h"

@interface CHGroupListTableViewController ()



@end

@implementation CHGroupListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Groups";
    
    ///
    /// Check to see if we are logged in. If we are not, login and stop.
    ///
    if( ![[CHNetworkManager sharedManager] hasStoredSessionToken] ) {
        UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        [self presentViewController:loginController animated:NO completion:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGroupsAndRefresh) name:@"ReloadGroupListTable" object:nil];
    
    ///
    /// Get the user profile to ensure we have a user
    ///
    CHNetworkManager *manager = [CHNetworkManager sharedManager];
    [manager getProfile:^(CHUser *userProfile) {
        
        [manager getAvatarOfUser:[[CHNetworkManager sharedManager] currentUser].userId callback:^(UIImage *avatar) {
            
            [manager currentUser].avatar = avatar;
        }];
    }];
    
    [self loadGroupsAndRefresh];
    
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        
    }];

}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    //set initial values here
        
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = [groups mutableCopy];
        
        // Get all member avatars
        for( CHGroup *group in self.groups ) {
            for( CHUser *user in group.members ) {
                if( user.avatar == nil ) {
                    [[CHNetworkManager sharedManager] getAvatarOfUser:user.userId callback:^(UIImage *avatar) {
                        ((CHUser *)group.memberDict[user.userId]).avatar = avatar;
                    }];
                }
            }
            
            for( CHUser *user in group.pastMembers ) {
                if( user.avatar == nil ) {
                    [[CHNetworkManager sharedManager] getAvatarOfUser:user.userId callback:^(UIImage *avatar) {
                        ((CHUser *)group.memberDict[user.userId]).avatar = avatar;
                    }];
                }
            }
        }
        [self loadGroupsAndRefresh];
        
    }];
    
}

- (void)loadGroupsAndRefresh;
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [self.tableView reloadData];
    [spinner stopAnimating];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHGroupTableViewCell" forIndexPath:indexPath];
    NSMutableString *cellText = [[self.groups[indexPath.row] getGroupName] mutableCopy];
    
    if( [[self.groups[indexPath.row] unread] intValue] > 0 ) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.groups[indexPath.row] unread]];
    }
    else {
        cell.detailTextLabel.text = @"";
    }
    cell.textLabel.text = cellText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CHMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
    [vc setGroup:_groups[indexPath.row]];
    [self.groups[indexPath.row] setUnread:[NSNumber numberWithInt:0]];

    [self.navigationController pushViewController:vc animated:YES];
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [[CHNetworkManager sharedManager] putLeaveGroup:((CHGroup *)self.groups[indexPath.row])._id callback:^(BOOL success, NSError *error) {
       
    }];
    [self.groups removeObjectAtIndex:indexPath.row];
    [tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return @"Leave";
}

@end
