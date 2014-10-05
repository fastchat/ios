//
//  CHMessageDetailTableViewController.m
//  Chat
//
//  Created by Ethan Mick on 9/27/14.
//
//

#import "CHMessageDetailTableViewController.h"
#import "CHGroup.h"
#import "CHDynamicCell.h"
#import "CHUser.h"
#import "CHUserSubtitleTableViewCell.h"

NSString *const kCHUserSubtitleTableViewCell = @"CHUserSubtitleTableViewCell";

@interface CHMessageDetailTableViewController ()

@property (nonatomic, copy) NSArray *options;

@end

@implementation CHMessageDetailTableViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.title = self.group.name;
    self.options = [self tableRepresentation];
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Messages Detail"];
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        if (self.group.pastMembers.count > 0) {
            return 3;
        } else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return self.group.members.count;
        } else {
            return self.group.pastMembers.count;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        return cell;
        
    } else {
        if (indexPath.section == 0) {
            NSDictionary *info = self.options[indexPath.row];
            CHDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:info[kCellIdentifier] forIndexPath:indexPath];
            [cell setCellValues:info withOwner:self];
            return cell;
        } else {
            CHUser *user = indexPath.section == 1 ? self.group.members[indexPath.row] : self.group.pastMembers[indexPath.row];
            CHUserSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCHUserSubtitleTableViewCell forIndexPath:indexPath];
            cell.cellLabel.text = user.username;
            cell.cellDetailLabel.text = @"User since XXX";
            
            static UIImage *defaultImage = nil;
            if (!defaultImage) {
                defaultImage = [UIImage imageNamed:@"NoAvatar"];
            }
            
            user.avatar.then(^(CHUser *user, UIImage *avatar) {
                cell.cellImageView.image = avatar;
            }).catch(^(NSError *error){
                cell.cellImageView.image = defaultImage;
            });
            
            return cell;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        if (section == 0) {
            return @"Options";
        } else if (section == 1) {
            return @"Members";
        } else {
            return @"Past Members";
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
#warning Add a User
        [self.group addUsers:@[]];
        return;
    } else {
        if (indexPath.section == 0) {
            NSDictionary *info = self.options[indexPath.row];
            void (^action)(NSIndexPath *) = info[@"action"];
            if (action) {
                action(indexPath);
                return;
            }
        }
    }
}

- (void)cell:(CHDynamicSwitchCell *)cell tapped:(UISwitch *)tapped;
{
    
}


- (NSArray *)tableRepresentation;
{
    NSMutableArray *container = [NSMutableArray array];
    
    NSMutableDictionary *silence = [NSMutableDictionary dictionary];
    silence[@"switchLabel.text"] = @"Silence this Group";
    silence[kCellIdentifier] = CHSwitchCell;
    silence[@"cellSwitch.on"] = @NO;
    silence[@"action"] = ^(NSIndexPath *path){
        CHDynamicSwitchCell *cell = (CHDynamicSwitchCell *)[self.tableView cellForRowAtIndexPath:path];
        [cell.cellSwitch setOn:!cell.cellSwitch.on animated:YES];
        [self cell:cell tapped:cell.cellSwitch];
    };
    [container addObject:silence];
    
    return container;
}

@end
