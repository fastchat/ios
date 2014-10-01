//
//  CHMessageViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import "CHSocketManager.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "SLKTextViewController.h"

@class CHGroup, CHProgressView;

@interface CHMessageViewController : SLKTextViewController <
    UITextViewDelegate,
    UITableViewDelegate,
    DBCameraViewControllerDelegate
>

@property (nonatomic, strong) CHGroup *group;
@property (nonatomic, copy) void (^loadInNewMessages)(NSArray *messageIDs);
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithGroup:(CHGroup *)group;
- (void)refreshOn:(BOOL)on;
- (PMKPromise *)messagesAtPage:(NSUInteger)page;

//@property (weak, nonatomic) IBOutlet UITableView *messageTable;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistance;
//@property (weak, nonatomic) IBOutlet UIView *messageBarView;
//@property (strong, nonatomic) IBOutlet CHProgressView *progressBar;
//
//@property (nonatomic, strong) UIView *containerView;
//@property (nonatomic, strong) HPGrowingTextView *textView;
//
//-(void)expandImage:(UIImage *)image;

@end
