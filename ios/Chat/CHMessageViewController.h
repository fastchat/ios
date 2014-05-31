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
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"

@class CHGroup;

@interface CHMessageViewController : UIViewController <UITextFieldDelegate, SocketIODelegate, UITableViewDataSource,UITableViewDelegate, CHSocketManagerDelegate, UITextViewDelegate, HPGrowingTextViewDelegate, DBCameraViewControllerDelegate>

@property (nonatomic, strong) CHGroup *group;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSDictionary *userIds;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITextView *messageEntryField;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistance;
@property (weak, nonatomic) IBOutlet UIView *messageBarView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property UIView *containerView;
@property HPGrowingTextView *textView;

-(void)expandImage:(UIImage *)image;

@end
