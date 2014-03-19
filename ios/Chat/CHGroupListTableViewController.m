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
#import "CHGroupTableViewCell.h"

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
   
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddView)];
    self.navigationItem.rightBarButtonItem = addButton;

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
    }];
    
}

- (void)showAddView {
    CHAddGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHAddGroupViewController"];   //[[WineAddViewController alloc] initWithNibName:@"WineAddViewController" bundle:Nil];
    //controller.delegate = self;
    //[self performSegueWithIdentifier:@"addWineSegue" sender:self];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Return the number of rows in the section.
    return self.groups.count;
}


- (CHGroupTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHGroupTableViewCell" forIndexPath:indexPath];

    // Configure the cell...
    cell.textLabel.text = [self.groups[indexPath.row] objectForKey:@"name"];
    DLog(@"group: %@", [self.groups[indexPath.row] objectForKey:@"name"]);
    
    return cell;
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
