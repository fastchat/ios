//
//  CHMessageIPadViewController.h
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"

@class CHUser;

@interface CHMessageIPadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SocketIODelegate>

@property (nonatomic, strong) CHUser *user;
@property (nonatomic, strong) NSDictionary *group;
@property (nonatomic, copy) NSDictionary *userIds;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)sendTapped:(id)sender;

@end
