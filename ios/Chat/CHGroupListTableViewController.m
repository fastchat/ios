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

@interface CHGroupListTableViewController ()

@property NSArray *groups;

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"My Groups";
    

    
    
    // Check to see if we are logged in
    if( ![[CHNetworkManager sharedManager] hasStoredSessionToken] ) {
        DLog(@"Session token not found. We need to login");

        CHViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewController"];
        [self presentViewController:loginController animated:NO completion:nil];
//        [self.navigationController presentModalViewController:loginController animated:NO];

//        [self.navigationController pushViewController:loginController animated:NO];
//        [self.navigationController presentViewController:loginController animated:NO completion:^{
//            DLog(@"Finished logging in");
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
        
    }
    
    else {
   
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    UIBarButtonItem *test = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(displaySideMenu)];

    self.navigationItem.leftBarButtonItem = test;

    


    
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //set initial values here
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = groups;
        
        DLog(@"groups: %@",groups);
        [self.tableView reloadData];
        [spinner stopAnimating];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }];
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        
    }];
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

    // Configure the cell...
    cell.textLabel.text = [self.groups[indexPath.row] objectForKey:@"name"];
    DLog(@"group: %@", [self.groups[indexPath.row] objectForKey:@"name"]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Open messageViewController with proper group id
    DLog(@"Opening group id: %@", [self.groups[indexPath.row] objectForKey:@"_id"]);
    [self.tableView setDelaysContentTouches:NO];
    CHMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
    //[controller setGroupId:[self.groups[indexPath.row] objectForKey:@"_id"]];
    [vc setGroupId:@"5336f917f2b3a00200000002"];
    
    vc.title = [self.groups[indexPath.row] objectForKey:@"name"];

    [self.navigationController pushViewController:vc animated:YES];
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
