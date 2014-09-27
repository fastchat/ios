//
//  CHProfileViewController.m
//  Chat
//
//  Created by Michael Caputo on 4/10/14.
//
//

#import "CHProfileViewController.h"
#import "CHNetworkManager.h"
#import "CHUser.h"
#import "CHGroup.h"
#import "CHMessage.h"
#import "UIActionSheet+PromiseKit.h"
#import "CHDynamicCell.h"

NSString *const CHPastGroupCellIdentifier = @"CHPastGroupCell";
NSString *const CHSwitchCell = @"CHSwitchCell";
NSString *const CHChevronCell = @"CHChevronCell";
NSString *const CHSubtextCell = @"CHSubtextCell";

NSString *const kTitleKey = @"TitleKey";
NSString *const kCellIdentifier = @"kCellIdentifier";
NSString *const kValueKey = @"kValueKey";
NSString *const kStoryboardIDKey = @"kStoryboardIDKey";

@interface CHProfileViewController ()

@property (weak, nonatomic) UIButton *cameraButton;
@property (nonatomic, strong) CHUser *user;
@property (nonatomic, copy) NSArray *settings;

@end

@implementation CHProfileViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.user = [CHUser currentUser];
    self.title = @"Profile";
    self.userNameLabel.text = self.user.username;
    self.settings = [self tableRepresentation];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    self.user.avatar.then(^(CHUser *user, UIImage *avatar){
        [self.avatarImageView setImage:avatar];
    }).catch(^(NSError *error){
        [self.avatarImageView setImage:[UIImage imageNamed:@"NoAvatar"]];
    });
}

#pragma mark - UITableView

//////////////////////////////////////////
//            SETTINGS
//////////////////////////////////////////
//           PAST GROUPS
//////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == 0) {
        return self.settings.count;
    } else {
        return self.user.pastGroups.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        NSDictionary *info = self.settings[indexPath.row];
        CHDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:info[kCellIdentifier] forIndexPath:indexPath];
        [cell setCellValues:info withOwner:self];
        return cell;
    } else {
        CHGroup *group = self.user.pastGroups[indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CHPastGroupCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = group.name;
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return NSLocalizedString(@"SETTINGS_HEADER", nil);
    } else {
        return NSLocalizedString(@"PAST_GROUPS_HEADER", nil);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *info = self.settings[indexPath.row];
    void (^action)() = info[@"action"];
    if (action) {
        action();
        return;
    }
    
    NSString *storyboardID = info[kStoryboardIDKey];
    if (storyboardID) {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
}

#pragma mark - Actions

- (IBAction)logout:(id)sender;
{
    [self.user logout:NO].then(^{
        [self finishLogout];
    });
}

- (IBAction)logoutFromAll:(id)sender;
{
    UIActionSheet *logout = [[UIActionSheet alloc] initWithTitle:@"Logout from All"
                                                        delegate:nil
                                               cancelButtonTitle:@"No"
                                          destructiveButtonTitle:@"Logout"
                                               otherButtonTitles:nil];
    [logout promiseInView:self.tabBarController.tabBar].then(^(NSNumber *index){
        if (index.integerValue == 0) {
            [self finishLogout];
        }
    });
}

- (void)finishLogout;
{
    UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CHViewNavController"];
    [self presentViewController:controller animated:YES completion:^{
        [self.tabBarController setSelectedIndex:0];
        [self.user MR_deleteEntity];
        [CHUser deleteAll];
        [CHGroup deleteAll];
        [CHMessage deleteAll];
    }];
}

- (void)openSettingNotification;
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Camera

- (IBAction)cameraButtonTouched:(id)sender;
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:
                                   [[DBCameraContainerViewController alloc] initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata;
{
    [self.user setAvatar:image];
    self.avatarImageView.image = image;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)dismissCamera:(id)cameraViewController;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table Setup

- (NSArray *)tableRepresentation;
{
    //inviting friends should be it's own entire Tab probably "friends, managing, finding, inviting, etc"
    
    // Paid Status
    
    NSMutableArray *container = [NSMutableArray array];
    
    NSMutableDictionary *payment = [NSMutableDictionary dictionary];
    payment[@"textLabel.text"] = @"Payment";
    payment[@"detailTextLabel.text"] = @"Member until XXX";
    payment[@"accessoryOption"] = @(UITableViewCellAccessoryDisclosureIndicator);
    payment[kStoryboardIDKey] = @"CHPaymentViewController";
    payment[kCellIdentifier] = CHSubtextCell;
    [container addObject:payment];
    
    NSMutableDictionary *doNotDisturb = [NSMutableDictionary dictionary];
    doNotDisturb[@"switchLabel.text"] = @"Do Not Disturb";
    doNotDisturb[kCellIdentifier] = CHSwitchCell;
    doNotDisturb[@"cellSwitch.on"] = @NO; //TODO: Get from Profile
    [container addObject:doNotDisturb];
    
    NSMutableDictionary *notifications = [NSMutableDictionary dictionary];
    notifications[@"textLabel.text"] = @"Notifications";
    notifications[@"accessoryOption"] = @(UITableViewCellAccessoryDisclosureIndicator);
    notifications[kCellIdentifier] = CHChevronCell;
    notifications[@"action"] = ^{
        [self openSettingNotification];
    };
    [container addObject:notifications];
    
    NSMutableDictionary *notePreviews = [NSMutableDictionary dictionary];
    notePreviews[@"switchLabel.text"] = @"Notification Previews";
    notePreviews[kCellIdentifier] = CHSwitchCell;
    notePreviews[@"cellSwitch.on"] = @YES;
    [container addObject:notePreviews];
    
    return container;
}

@end
