//
//  CHMessageViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHMessageViewController.h"
#import "CHNetworkManager.h"
#import "SocketIOPacket.h"
#import "CHInviteUserViewController.h"
#import "CHUser.h"
#import "CHOwnMessageTableViewCell.h"
#import "CHSocketManager.h"
#import "CHGroup.h"
#import "CHMessage.h"
#import "CHCircleImageView.h"
#import "URBMediaFocusViewController.h"
#import "HPTextViewInternal.h"
#import "CHBackgroundContext.h"
#import "CHProgressView.h"
#import "UIAlertView+PromiseKit.h"
#import "TSMessage.h"
#import <AudioToolbox/AudioToolbox.h>

#define kDefaultContentOffset self.navigationController.navigationBar.frame.size.height + 20

//NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
//NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) URBMediaFocusViewController *mediaFocus;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIResponder *previousResponder;
@property (nonatomic, assign) BOOL beingDismissed;
@property (nonatomic, assign) CGFloat heightOfKeyboard;

@property (nonatomic, assign) BOOL shouldScroll;
@property (nonatomic, assign) BOOL shouldSlide;
@property (nonatomic, assign) BOOL keyboardIsVisible;
@property (nonatomic, assign) BOOL mediaWasAdded;
@property (nonatomic, strong) UIImage *media;

@property (nonatomic, strong) CHMessageTableDelegate *delegate;

@end

@implementation CHMessageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Messages"];
    
    self.view.backgroundColor = kLightBackgroundColor;
    self.messageTable.backgroundColor = kLightBackgroundColor;
    
    self.shouldSlide = YES;
    self.title = _group.name;
    _beingDismissed = NO;
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, screenWidth, 40)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.containerView addSubview:line];
    
    //UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"Attach"] forState:UIControlStateNormal];
	cameraBtn.frame = CGRectMake(0, 0, 40, 40);
    cameraBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
    [cameraBtn addTarget:self action:@selector(loadCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:cameraBtn];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 2, screenWidth - (36 + 45 + 10), 36)];
    self.textView.isScrollable = NO;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 4.0;
    self.textView.layer.masksToBounds = YES;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.internalTextView.typingAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    self.textView.maxHeight = 140.0f;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = @"Send FastChat";
    self.textView.delegate = self;
    
    [self.containerView addSubview:self.textView];
    [self.view addSubview:self.containerView];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem]; //[UIButton buttonWithType:UIButtonTypeCustom];
	_sendButton.frame = CGRectMake(self.containerView.frame.size.width - 42, 1, 42, 40);
    _sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
 	[self.containerView addSubview:_sendButton];
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                           0,
                                           self.containerView.frame.size.height,
                                           0);
    self.messageTable.contentInset = insets;
    self.messageTable.scrollIndicatorInsets = insets;
    
    self.mediaWasAdded = NO;
    self.delegate = [[CHMessageTableDelegate alloc] initWithTable:self.messageTable group:self.group];
    self.delegate.delegate = self;
    
    
    DLog(@"End Middle");
    
    self.keyboardIsVisible = NO;
    [self setSendButtonEnabled:[self canSendMessage]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

-(void)sendUserTypingAction;
{
    DLog(@"User changed text field");
}

#pragma mark - Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)notification;
{
    CGFloat keyboardHeight = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = (curve << 16);
    
    self.previousResponder = self.textView;
    self.heightOfKeyboard = keyboardHeight;
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:options
                     animations:^{
                         [self setTableViewInsetsFromBottom:keyboardHeight];
                         ////// This may need some logic to scroll the text view with the keyboard
                         [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                                                    indexPathForRow:([self.delegate tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                                                  atScrollPosition:UITableViewScrollPositionBottom
                                                          animated:YES];
                         
                         CGRect containerFrame = self.containerView.frame;
                         containerFrame.origin.y = self.view.bounds.size.height - (keyboardHeight + containerFrame.size.height);
                         self.containerView.frame = containerFrame;
                     } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification;
{
    if (_beingDismissed) {
        return;
    }
    self.heightOfKeyboard = 0;
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = (animationCurve << 16);
        
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:options
                     animations:^{
                        [self setTableViewInsetsFromBottom:0];
                             
                         CGRect containerFrame = self.containerView.frame;
                         containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
                         self.containerView.frame = containerFrame;
                     } completion:^(BOOL finished) {
                             
                         self.previousResponder = nil;
                     }];
 /////// This may need some logic to scroll the messages with the keyboard
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                               indexPathForRow:([self.delegate tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
}

#pragma mark - Message Methods

- (void)resignTextView;
{
	[self.textView resignFirstResponder];
}

- (void)sendMessage;
{
    [self startSendingMessage];
    NSString *msg = self.textView.text;
    
    if ( !msg.length ) {
        return;
    }
    
    CHUser *user = [CHUser currentUser];
    
    CHMessage *newMessage = [CHMessage MR_createEntity];
    newMessage.text = msg;
    newMessage.author = user;
    newMessage.group = self.group;
    newMessage.sent = [NSDate date];
    
    UIImage *media = self.textView.internalTextView.attachedImage;
    if (media) {
        newMessage.hasMedia = @YES;
        newMessage.theMediaSent = media;
    }
    
    [self.group addMessagesObject:newMessage];
    [self addNewMessage:newMessage];
    
    [user sendMessage:newMessage toGroup:self.group].then(^(CHMessage *mes){
        [self.delegate addMessage:mes];
    }).catch(^(NSError *error) {
        return [[[UIAlertView alloc] initWithTitle:@"Error!"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Darn"
                          otherButtonTitles:nil] promise];
    }).finally(^{
        [self endSendingMessage];
    });
    
    self.textView.text = @"";
}

- (void)addNewMessage:(CHMessage *)message;
{
    self.shouldSlide = NO;
    
    if( self.keyboardIsVisible ) {
        [self.textView setKeyboardType:UIKeyboardTypeDefault];
        [self.textView resignFirstResponder];
        [self.textView becomeFirstResponder];
    }
    
    self.media = nil;
    self.mediaWasAdded = NO;
    [self setSendButtonEnabled:[self canSendMessage]];
}

#pragma mark - Progress Bar

- (void)startSendingMessage;
{
    if (!self.progressBar) {
        self.progressBar = [CHProgressView viewWithFrame:CGRectMake(0, -20, [[UIScreen mainScreen] bounds].size.width, 20)];
        self.progressBar.hidden = YES;
        self.progressBar.backgroundColor = [UIColor clearColor];
        [self.progressBar setProgressColor:kProgressBarColor];
        [self.navigationController.navigationBar addSubview:self.progressBar];
    }
    
    self.progressBar.progress = 0;
    self.progressBar.hidden = NO;
    [self.progressBar setProgress:0.8 animated:YES];
}

- (void)endSendingMessage;
{
    [self.progressBar setProgress:1 animated:YES].then(^{
        self.progressBar.hidden = YES;
    });
}

- (void)expandImage:(UIImage *)image;
{
    if (!image) {
        return;
    }
    
    self.mediaFocus = [[URBMediaFocusViewController alloc] init];
    [self.mediaFocus showImage:image fromView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = self.delegate.messages[indexPath.row];
    
    self.shouldSlide = YES;
    [self resignTextView];
    
    if (message.hasMediaValue) {
        message.media.then(^(UIImage *image){
            [self expandImage:image];
        });
    }
}

/**
 * Sets the insets just how we want them, with whatever distance from the
 * bottom of the screen (which will change, depending on the height of the textview,
 * and if the keyboard is up.
 */
- (void)setTableViewInsetsFromBottom:(CGFloat)bottomDistance;
{
    //    UIEdgeInsetsMake(top, left, bottom, right)
    UIEdgeInsets insets = UIEdgeInsetsMake(kDefaultContentOffset,
                                           0,
                                           self.containerView.frame.size.height + bottomDistance,
                                           0);
    self.messageTable.contentInset = insets;
    self.messageTable.scrollIndicatorInsets = insets;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.containerView.frame = r;

    // Resize table
    [self setTableViewInsetsFromBottom:self.heightOfKeyboard];

    if (_group.messages.count > 0) {
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                                   indexPathForRow:([self.delegate tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:YES];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if (self.textView.text.length > range.location ) {
        NSInteger character = [self.textView.text characterAtIndex:range.location];
        if (character == NSAttachmentCharacter) {
            
            DLog(@"DELETED ATTACHMENT");
            self.textView.internalTextView.attachedImage = nil;
        }
    }
       return YES;
}

- (void)textViewTapped:(UITapGestureRecognizer *)sender;
{
    [self tableView:self.messageTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.view.tag inSection:0]];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;
{
    [self setSendButtonEnabled:[self canSendMessage]];
}

- (void)otherGroupMessage:(CHMessage *)message;
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:message.group.name
                                       subtitle:message.text
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:^{
                                           //                                           UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                                           //                                           CHMessageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CHMessageViewController"];
                                           //                                           vc.group = message.group;
                                           //                                           vc.groupId = message.groupId;
                                           //
                                           //                                           [((UINavigationController*)root) popViewControllerAnimated:NO];
                                           //                                           [((UINavigationController*)root) pushViewController:vc animated:YES];
                                       }
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

#pragma mark - Camera

-(void)loadCamera;
{
    /*
     Fix for DBCamera crashing when you open your photo library:
     
     NSURL *url = [[result defaultRepresentation] url];
     if( url ) {
     [items addObject:url];
     }
     
     Add this to their file. at the line it crashes at DBLibraryManager.
     */
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DBCameraContainerViewController alloc] initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata;
{
    self.mediaWasAdded = YES;
    self.shouldSlide = NO;
    [self.textView.internalTextView addImage:image];

    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self setSendButtonEnabled:[self canSendMessage]];
}

- (void)setSendButtonEnabled:(BOOL)enabled;
{
    [self.sendButton setEnabled:enabled];
}

- (BOOL)canSendMessage;
{
    return self.textView.text.length > 0 || self.textView.internalTextView.attachedImage != nil;
}

- (void)dismissCamera:(id)cameraViewController;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
