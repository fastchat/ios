//
//  CHMessageViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"

@interface CHMessageViewController : UIViewController <UITextFieldDelegate, SocketIODelegate, UITableViewDataSource,UITableViewDelegate>
//@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
//@property (weak, nonatomic) IBOutlet UIButton *sendButton;
//@property (weak, nonatomic) IBOutlet UIScrollView *chatScrollView;
//@property (weak, nonatomic) IBOutlet UITextView *messageDisplayTextView;
@property (strong, nonatomic) NSString *groupId;
@property (nonatomic, strong) NSDictionary *group;
@property (nonatomic, strong) NSDictionary *userIds;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;

@property (strong, nonatomic) IBOutlet UIImageView *screenShotImageView;
@property (strong, nonatomic) UIImage *screenShotImage;

- (IBAction)sendButtonTouched:(id)sender;
@end
