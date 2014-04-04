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
#import "CHViewController.h"
#import "CHMessageTableViewController.h"
#import "CHGroupTableViewCell.h"
#import "NSDate+TimeAgo.h"
#import "CHMessageIPadViewController.h"

@interface CHGroupListTableViewController ()

@property (nonatomic, strong) CHUser *user;
@property NSArray *groups;

@end

@implementation CHGroupListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"My Groups";
    
    // Check to see if we are logged in
    if( ![[CHNetworkManager sharedManager] hasStoredSessionToken] ) {
        DLog(@"Session token not found. We need to login");

        UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        loginController.modalPresentationStyle = UIModalPresentationFormSheet;
        loginController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:loginController animated:NO completion:nil];
        return;
    }
    
    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = groups;
        [self.tableView reloadData];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }];
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        self.user = userProfile;
    }];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(displaySideMenu)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)displaySideMenu {
    CHSideNavigationTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHSideNavigationTableViewController"];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)showAddView {
    CHAddGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHAddGroupViewController"];
    
    [[self navigationController] pushViewController:controller animated:YES];
}

- (NSDateFormatter *)formatter;
{
    static NSDateFormatter *_formatter = nil;
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"]; //2014-03-29T17:08:39.871Z"
    }
    return _formatter;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHGroupTableViewCell" forIndexPath:indexPath];
    
    ///
    /// One day, just make this the default
    ///
    if (IPAD) {
        CHGroupTableViewCell *c = (CHGroupTableViewCell *)cell;
        c.groupTextLabel.text = _groups[indexPath.row][@"name"];
        c.groupDetailLabel.text = @"This is the last message sent! I hope you enjoy it.";
        c.groupDetailRightLabel.text = [[[self formatter] dateFromString:@"2014-03-29T17:08:37.194Z"] timeAgo];
        return c;
        
    }

    // Configure the cell...
    cell.textLabel.text = [self.groups[indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (IPAD) {
        CHMessageIPadViewController *messages = [self.splitViewController.viewControllers[1] viewControllers][0];
        messages.user = _user;
        messages.group = _groups[indexPath.row];
        return;
    }
    
    // Open messageViewController with proper group id
    DLog(@"Opening group id: %@", [self.groups[indexPath.row] objectForKey:@"_id"]);
    [self.tableView setDelaysContentTouches:NO];
    CHMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
//    CHMessageTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHMessageTableViewController"];
    //[controller setGroupId:[self.groups[indexPath.row] objectForKey:@"_id"]];
    [vc setGroupId:_groups[indexPath.row][@"_id"]];
    [vc setGroup:_groups[indexPath.row]];
    
    vc.title = [self.groups[indexPath.row] objectForKey:@"name"];

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISplitView Controller

- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;
{
    return NO;
}

@end
