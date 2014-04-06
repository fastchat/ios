//
//  CHMessageViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "CHSocketManager.h"
#import "HPGrowingTextView.h"

@interface CHMessageViewController : UIViewController <UITextFieldDelegate, SocketIODelegate, UITableViewDataSource,UITableViewDelegate, CHSocketManagerDelegate, UITextViewDelegate, HPGrowingTextViewDelegate>

@property (strong, nonatomic) NSString *groupId;
@property (nonatomic, strong) NSDictionary *group;
@property (nonatomic, strong) NSDictionary *userIds;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITextView *messageEntryField;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistance;
@property (weak, nonatomic) IBOutlet UIView *messageBarView;

@property UIView *containerView;
@property HPGrowingTextView *textView;

- (IBAction)sendButtonTouched:(id)sender;


@end
