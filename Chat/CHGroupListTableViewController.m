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
#import "CHUnreadView.h"
#import "CHBackgroundContext.h"

#define kSecondsInDay 86400

@interface CHGroupListTableViewController ()

@end

@implementation CHGroupListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Groups"];
    self.view.backgroundColor = kLightBackgroundColor;
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:@"ReloadGroupTablesNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[NSManagedObjectContext MR_defaultContext]];
    
    __block dispatch_queue_t q = [CHBackgroundContext backgroundContext].queue;
    
    [self user].thenOn(q, ^(CHUser *user) {
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:
                                                    UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                                                                     categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        self.currentUser = user;
        [self reloadTableView];
        return user.remoteGroups;
    }).thenOn(q, ^(CHUser *user){
        [self reloadTableView];
        return user.avatar;
    }).catchOn(q, ^(NSError *error){
        DLog(@"Error Occured! %@", error);
    });
}

- (PMKPromise *)user;
{
    if (!CHUser.currentUser.isLoggedIn) {
        CHLoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
        return [self promiseViewController:loginController animated:NO completion:nil];
    } else {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
            fulfiller([CHUser currentUser]);
        }];
    }
}

- (void)reloadTableView;
{
    DLog(@"reloading table view");
    
    void (^reload)() = ^{ [self.tableView reloadData]; };
    
    if ([NSThread isMainThread]) {
        reload();
    } else {
        dispatch_async(dispatch_get_main_queue(), reload);
    }
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)contextDidChange:(NSNotification *)notification;
{
    NSArray *updatedObjects = [[[notification userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    NSArray *insertedObjects = [[[notification userInfo] objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *updatedOrInserted = [updatedObjects arrayByAddingObjectsFromArray:insertedObjects];
    
    if (updatedOrInserted.count > 0) {
        NSArray *groups = [updatedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject isKindOfClass:[CHGroup class]];
        }]];
        
        if (groups.count > 0) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _currentUser.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CHGroupTableViewCell" forIndexPath:indexPath];
    
    CHGroup *group = _currentUser.groups[indexPath.row];
    
    cell.groupTextLabel.text = group.name;
    cell.groupDetailLabel.text = group.lastMessage.text;
    cell.groupRightDetailLabel.text = [self formatTime:group.lastMessage.sent];
    [cell setUnread:[group hasUnread]];
    
    UIColor *background = kLightBackgroundColor;
    if ([group isEmpty]) {
        background = kDarkerGrayBackgroundColor;
    }
    [cell setBackgroundColor:background];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

    CHGroup *group = _currentUser.groups[indexPath.row];
    CHMessageViewController *vc = [[CHMessageViewController alloc] initWithGroup:group];

    [group setUnreadValue:0];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView beginUpdates];
    [_currentUser leaveGroupAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return @"Leave";
}

#pragma mark - Time Formatting

- (NSString *)formatTime:(NSDate *)date;
{
    if (!date) {
        return @"";
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
                                          fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
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
    
    NSDateComponents *componentsYesterday = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
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

@end
