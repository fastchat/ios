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

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Groups";
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGroupsAndRefresh) name:@"ReloadGroupListTable" object:nil];

    
    
    // Check to see if we are logged in
    if( ![[CHNetworkManager sharedManager] hasStoredSessionToken] ) {
        UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        [self presentViewController:loginController animated:NO completion:nil];
    }
    
    else {
        // Get the user profile to ensure we have a user
        [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
            [[CHNetworkManager sharedManager] getAvatarOfUser:[[CHNetworkManager sharedManager] currentUser].userId callback:^(UIImage *avatar) {

                [[CHNetworkManager sharedManager] currentUser].avatar = avatar;
            }];
        }];

        [self loadGroupsAndRefresh];

        
    }
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        
    }];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showAddView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(displaySideMenu)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
}

-(void) viewWillAppear:(BOOL)animated
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

-(void) loadGroupsAndRefresh;
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [self.tableView reloadData];
    [spinner stopAnimating];
}

- (void)displaySideMenu {
    CHSideNavigationTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHSideNavigationTableViewController"];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)showAddView {
    CHAddGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHAddGroupViewController"];
    
    [[self navigationController] pushViewController:controller animated:YES];
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
