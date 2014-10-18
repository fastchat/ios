//
//  CHMessageDetailTableViewController.h
//  Chat
//
//  Created by Ethan Mick on 9/27/14.
//
//

#import <UIKit/UIKit.h>
#import "CHDynamicSwitchCell.h"

@class CHGroup;

@interface CHMessageDetailTableViewController : UITableViewController <CHDynamicSwitchDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) CHGroup *group;

@end
