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
#import "CHGroup.h"

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
        DLog(@"Session token not found. We need to login");

        UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        [self presentViewController:loginController animated:NO completion:nil];
    }
    
    else {
    
        [self loadGroupsAndRefresh];
        
    }

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showAddView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(displaySideMenu)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
    
    
}

-(void) loadGroupsAndRefresh;
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = groups;

        [self.tableView reloadData];
        [spinner stopAnimating];
        
    }];
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        
    }];
    }

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //set initial values here
        
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

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

    cell.textLabel.text = [self.groups[indexPath.row] getGroupName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CHMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
    [vc setGroup:_groups[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
