//
//  CHGroupListTableViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@class CHUser;

@interface CHGroupListTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CHUser *currentUser;
- (IBAction)newGroup:(id)sender;

@end
