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
#import "CHMessageViewController.h"
#import "CHLoginViewController.h"
#import "CHGroup.h"
#import "CHUser.h"
#import "MBProgressHUD.h"
#import "CHGroupTableViewCell.h"
#import "CHMessage.h"

#define kSecondsInDay 86400

@interface CHGroupListTableViewController ()

@end

@implementation CHGroupListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Groups";
    self.view.backgroundColor = kLightBackgroundColor;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = insets;
    
    ///
    /// Check to see if we are logged in. If we are not, login and stop.
    ///
    if( ![[CHNetworkManager sharedManager] hasStoredSessionToken] ) {
        UIViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        [self presentViewController:loginController animated:NO completion:nil];
        return;
    }
    
    ///
    /// Get the user profile to ensure we have a user
    ///
    CHNetworkManager *manager = [CHNetworkManager sharedManager];
    [manager getProfile:^(CHUser *userProfile) {
        
        [manager getAvatarOfUser:[[CHNetworkManager sharedManager] currentUser].userId callback:^(UIImage *avatar) {
            
            [manager currentUser].avatar = avatar;
        }];
    }];
    
    [self.tableView reloadData];
    
    
    [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
        
    }];

}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];

    ///
    /// If we got here, it means we logged in
    ///
        
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
        self.groups = [groups mutableCopy];
        
        // Get all member avatars
        for( CHGroup *group in self.groups ) {
            
            [group.members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CHUser *user = obj;
                if( user.avatar == nil ) {
                    [[CHNetworkManager sharedManager] getAvatarOfUser:user.userId callback:^(UIImage *avatar) {
                        ((CHUser *)group.memberDict[user.userId]).avatar = avatar;
                    }];
                }
            }];
            
            [group.pastMembers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CHUser *user = obj;
                if( user.avatar == nil ) {
                    [[CHNetworkManager sharedManager] getAvatarOfUser:user.userId callback:^(UIImage *avatar) {
                        ((CHUser *)group.memberDict[user.userId]).avatar = avatar;
                    }];
                }
            }];

        }
        [self.tableView reloadData];
    }];
}

- (NSString *)formatTime:(NSDate *)date;
{
    if (!date) {
        return @"";
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                          fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                        fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    // if today
    if([today isEqualToDate:otherDate]) {
        static NSDateFormatter *formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"h:mm a"];
        }
        return [formatter stringFromDate:date];
    }
    
    NSDateComponents *componentsYesterday = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                          fromDate:[NSDate dateWithTimeIntervalSinceNow:-kSecondsInDay]];
    NSDate *yesterday = [cal dateFromComponents:componentsYesterday];
    // if yesterday
    if ([yesterday isEqualToDate:otherDate]) {
        return @"Yesterday";
    }
    
    // if within a week (get weekday and say "sunday"
    // do this later.
    
    //else, show date 5/12/14
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d/M/yy"];
    }
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHGroupTableViewCell" forIndexPath:indexPath];
    
    CHGroup *group = _groups[indexPath.row];
    cell.groupTextLabel.text = group.groupName;
    cell.groupDetailLabel.text = group.lastMessage.text;
    cell.groupRightDetailLabel.text = [self formatTime:group.lastMessage.sent];
    [cell setUnread:[group hasUnread]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHGroupTableViewCell *groupCell = (CHGroupTableViewCell *)cell;
    [groupCell.groupDetailLabel sizeThatFits:groupCell.groupDetailLabel.frame.size];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([segue.identifier isEqualToString:@"push CHMessageViewControllerFrom CHGroupListTableViewController"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CHMessageViewController *vc = segue.destinationViewController;
        
        CHGroup *group = _groups[indexPath.row];
        group.unread = @0;
        [vc setGroup:group];
        
        [self.tableView reloadData];
    }
}

@end
