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
NSString *const CHChevronCell = @"CHChevronCell";
NSString *const CHSubtextCell = @"CHSubtextCell";

NSString *const kTitleKey = @"TitleKey";
NSString *const kValueKey = @"kValueKey";
NSString *const kStoryboardIDKey = @"kStoryboardIDKey";

@interface CHProfileViewController ()

@property (weak, nonatomic) UIButton *cameraButton;
@property (nonatomic, strong) CHUser *user;
@property (nonatomic, copy) NSArray *settings;
@property (nonatomic, copy) NSDictionary *privacyPolicy;

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
    self.privacyPolicy = @{kCellIdentifier: @"",
                           @"textLabel.text": @"Privacy Policy",
                           kStoryboardIDKey: @"CHPrivacyPolicyViewController",
                           @"accessoryOption": @(UITableViewCellAccessoryDisclosureIndicator)
                           };
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!self.user) {
        return 0;
    }
    if (section == 0) {
        return self.settings.count;
    } else if (section == 1){
        return self.user.pastGroups.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        NSMutableDictionary *info = self.settings[indexPath.row];
        info[@"indexPath"] = indexPath;
        CHDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:info[kCellIdentifier] forIndexPath:indexPath];
        [cell setCellValues:info withOwner:self];
        return cell;
    } else if (indexPath.section == 1){
        CHGroup *group = self.user.pastGroups[indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CHPastGroupCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = group.name;
        return cell;
    } else {
        CHDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:CHChevronCell forIndexPath:indexPath];
        [cell setCellValues:_privacyPolicy withOwner:self];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return NSLocalizedString(@"SETTINGS_HEADER", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"PAST_GROUPS_HEADER", nil);
    } else {
        return @"Policies";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *info = nil;
    
    if (indexPath.section == 0) {
        info = self.settings[indexPath.row];
    } else if (indexPath.section == 2) {
        info = self.privacyPolicy;
    }

    void (^action)(NSIndexPath *) = info[@"action"];
    if (action) {
        action(indexPath);
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

- (void)cell:(CHDynamicSwitchCell *)cell tapped:(UISwitch *)tapped;
{
    [self.user promiseDoNotDisturb:tapped.on].then(^{
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    });
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
    
    NSMutableDictionary *notifications = [NSMutableDictionary dictionary];
    notifications[@"textLabel.text"] = @"Notifications";
    notifications[@"accessoryOption"] = @(UITableViewCellAccessoryDisclosureIndicator);
    notifications[kCellIdentifier] = CHChevronCell;
    notifications[@"action"] = ^(NSIndexPath *path){
        [self openSettingNotification];
    };
    [container addObject:notifications];
    
    NSMutableDictionary *doNotDisturb = [NSMutableDictionary dictionary];
    doNotDisturb[@"switchLabel.text"] = @"Do Not Disturb";
    doNotDisturb[kCellIdentifier] = CHSwitchCell;
    doNotDisturb[@"cellSwitch.on"] = self.user.doNotDisturb ? self.user.doNotDisturb : @NO;
    doNotDisturb[@"action"] = ^(NSIndexPath *path){
        CHDynamicSwitchCell *cell = (CHDynamicSwitchCell *)[self.tableView cellForRowAtIndexPath:path];
        [cell.cellSwitch setOn:!cell.cellSwitch.on animated:YES];
        [self cell:cell tapped:cell.cellSwitch];
    };
    [container addObject:doNotDisturb];
    
    NSMutableDictionary *notePreviews = [NSMutableDictionary dictionary];
    notePreviews[@"switchLabel.text"] = @"Notification Previews";
    notePreviews[kCellIdentifier] = CHSwitchCell;
    notePreviews[@"cellSwitch.on"] = @YES;
    [container addObject:notePreviews];
    
    return container;
}

@end
