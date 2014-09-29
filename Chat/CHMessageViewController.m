//
//  CHMessageViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHMessageViewController.h"
#import "CHMessage.h"
#import "CHUser.h"
#import "CHGroup.h"
#import "CHMessageTableViewCell.h"
#import "CHBackgroundContext.h"

#define kDefaultContentOffset self.navigationController.navigationBar.frame.size.height + 20

NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageViewController ()

@property (nonatomic, assign) NSInteger page;
@property (atomic, copy) NSArray *messageIDs;
@property (nonatomic, strong) NSMutableOrderedSet *messages;
@property (nonatomic, copy) void (^loadInNewMessages)(NSArray *messageIDs);

//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
//
//@property (nonatomic, strong) URBMediaFocusViewController *mediaFocus;
//@property (nonatomic, strong) UIButton *sendButton;
//@property (nonatomic, strong) UIResponder *previousResponder;
//@property (nonatomic, assign) BOOL beingDismissed;
//@property (nonatomic, assign) CGFloat heightOfKeyboard;
//
//@property (nonatomic, assign) BOOL shouldScroll;
//@property (nonatomic, assign) BOOL shouldSlide;
//@property (nonatomic, assign) BOOL keyboardIsVisible;
//@property (nonatomic, assign) BOOL mediaWasAdded;
//@property (nonatomic, strong) UIImage *media;
//
//@property (nonatomic, strong) CHMessageTableDelegate *delegate;

@end

@implementation CHMessageViewController

#pragma mark - View Lifecycle

- (instancetype)initWithGroup:(CHGroup *)group;
{
    self = [super init];
    if (self) {
        self.page = 0;
        self.group = group;
        self.messages = [NSMutableOrderedSet orderedSet];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.title = self.group.name;
        self.view.backgroundColor = kLightBackgroundColor;
        
        [self.tableView registerNib:[UINib nibWithNibName:@"CHMessageTableViewCell" bundle:nil]
             forCellReuseIdentifier:CHMesssageCellIdentifier];

        [self.tableView registerNib:[UINib nibWithNibName:@"CHOwnMessageTableViewCell" bundle:nil]
             forCellReuseIdentifier:CHOwnMesssageCellIdentifier];
        
        __weak CHMessageViewController *this = self;
        self.loadInNewMessages = ^(NSArray *messageIDs) {
            DLog(@"WHAT: %@", messageIDs);
            __strong CHMessageViewController *strongSelf = this;
            if(strongSelf) {
                DLog(@"WHATtttt");
                strongSelf.messageIDs = messageIDs;
                @synchronized(strongSelf) {
                    for (NSManagedObjectID *anID in strongSelf.messageIDs) {
                        
                        CHMessage *message = [CHMessage objectID:anID toContext:[NSManagedObjectContext MR_defaultContext]];
                        DLog(@"WHAT: %@", message);
                        if (message) {
                            [strongSelf.messages addObject:message];
                        }
                    }
                    strongSelf.messageIDs = nil;
                }
                
                DLog(@"FUCK: %@", strongSelf.messages);
                
//                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
//                [strongSelf.messages sortUsingDescriptors:@[sortDescriptor]];
                [strongSelf.tableView reloadData];
                
//                CGPoint offset = CGPointMake(0, strongSelf.tableView.contentSize.height - strongSelf.tableView.frame.size.height);
//                [strongSelf.tableView setContentOffset:offset animated:NO];
            }
        };
        
        [self messagesAtPage:self.page];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
//    [self.typingIndicatorView insertUsername:@"Ethan"];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = self.messages[indexPath.row];
    CHMessageTableViewCell *cell;
    UIColor *color = [UIColor whiteColor];
    CHUser *author = message.getAuthorNonRecursive;

    if ( [message.author isEqual:[CHUser currentUser]] ) {
        cell = [tableView dequeueReusableCellWithIdentifier:CHOwnMesssageCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CHMesssageCellIdentifier forIndexPath:indexPath];
        color = [UIColor blackColor];
    }
    
    cell.transform = tableView.transform;

    NSDictionary *attributes = @{NSForegroundColorAttributeName: color,
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0]};
    cell.messageTextView.text = nil;
    cell.messageTextView.attributedText = nil;
    cell.messageTextView.attributedText = [[NSAttributedString alloc] initWithString:message.text ? message.text : @""
                                                                          attributes:attributes];
    cell.authorLabel.text = author.username;
    cell.timestampLabel.text = @"wat";//[self formatDate:message.sent];
    
    static UIImage *defaultImage = nil;
    if (!defaultImage) {
        defaultImage = [UIImage imageNamed:@"NoAvatar"];
    }
    
    cell.authorLabel.textColor = author.color;
    
    /**
     * The author may actually not exist if you have a message
     * from the system.
     */
    if (author) {
        author.avatar.then(^(CHUser *user, UIImage *avatar) {
            cell.avatarImageView.image = avatar;
        }).catch(^(NSError *error){
            cell.avatarImageView.image = defaultImage;
        });
    } else {
        cell.authorLabel.textColor = color;
        cell.avatarImageView.image = defaultImage;
    }
    
    /// Remove all gesture recognizers on cell reuse
    for (UIGestureRecognizer *recognizer in cell.gestureRecognizers) {
        [cell removeGestureRecognizer:recognizer];
    }
    if (message.hasMediaValue) {
        message.media.then(^(UIImage *image){
            CGSize size = [self boundsForImage:image];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            [cell.messageTextView addGestureRecognizer:tap];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:message.text]];
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [string addAttributes:attributes range:NSMakeRange(0, string.length)];
            cell.messageTextView.attributedText = string;
        });
    }
    
    return cell;
}

/**
 * Let's help the tableview out some. Most people send 1 line messages, and that makes our
 * cells 49 pixels high.
 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = self.messages[indexPath.row];
    if (message.rowHeightValue > 0) {
        return message.rowHeightValue;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = self.messages[indexPath.row];
    if (message.rowHeightValue > 0) {
        return message.rowHeightValue;
    }
    
    CGRect rect = [message.text boundingRectWithSize:CGSizeMake(205 - 16, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                             context:nil];
    
    CGFloat height = rect.size.height;
    // Adding 45.0 to fix the bug where messages of certain lengths don't size the cell properly.
    if( message.hasMedia.boolValue) {
        height += 150.0f;
    }
    height += 45.0f;
    
    DLog(@"Height: %f", height);
    
    message.rowHeightValue = height;
    return height;
}


- (NSString *)formatDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }
    
    static NSDateFormatter *timestampFormatter = nil;
    if (!timestampFormatter) {
        timestampFormatter = [[NSDateFormatter alloc] init];
        [timestampFormatter setDateStyle:NSDateFormatterLongStyle];
        timestampFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        timestampFormatter.dateFormat = @"MMM dd, HH:mm";
    }
    return [timestampFormatter stringFromDate:date];
}

- (CGSize)boundsForImage:(UIImage *)image;
{
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    CGFloat max = 150.0;
    
    if (height > width && height > max) {
        CGFloat ratio = height / max;
        height = height / ratio;
        width = width / ratio;
    } else if (width >= height && width > max) {
        CGFloat ratio = width / max;
        height = height / ratio;
        width = width / ratio;
    }
    return CGSizeMake(width, height);
}

#pragma mark - Messages

/**
 * The idea here is simple. We start off with an immediate small batch of xx messages
 * (it has to be enough so you can't see the top of the screen), then because most often
 * this will probaby be the case, we immediatly fetch the next YY. This is also good if
 * people are sending messages and you want to get the latest).
 *
 * When we "fetch", we always do it from the background, and then return the ObjectID's to
 * the messageID array. The main thread will use these ID's to do the fetch, which is almost
 * instant in Core Data (hash lookup and probably cached).
 *
 * When the UI gets the messageID's that are waiting, it then queues the next background
 * fetch to get the next batch (local + server). This ensures we are always 1 step ahead,
 * and things run fast.
 */
- (PMKPromise *)messagesAtPage:(NSUInteger)page;
{
    id q = [CHBackgroundContext backgroundContext].queue;
    NSManagedObjectContext *context = [CHBackgroundContext backgroundContext].context;
    
    return dispatch_promise_on(q, ^{
        return [self localMessagesAtPage:page context:context];
    }).thenOn(q, ^(NSArray *local){
        NSMutableArray *newMessageIDS = [NSMutableArray array];
        for (CHMessage *message in local) {
            [newMessageIDS addObject:message.actualObjectId];
        }
        return newMessageIDS;
    }).then(_loadInNewMessages)
    .thenOn(q, ^{
        return [self.group remoteMessagesAtPage:self.page];
    }).thenOn(q, ^{
        [context reset];
        NSMutableArray *newMessageIDS = [NSMutableArray array];
        NSArray *final = [self localMessagesAtPage:page context:context];
        for (CHMessage *message in final) {
            [newMessageIDS addObject:message.actualObjectId];
        }
        return newMessageIDS;
    });
}

- (NSArray *)localMessagesAtPage:(NSUInteger)page context:(NSManagedObjectContext *)context;
{
    NSPredicate *messages = [NSPredicate predicateWithFormat:@"SELF.group == %@ AND SELF.chID != nil", self.group];
    NSFetchRequest *fetchRequest = [CHMessage MR_requestAllWithPredicate:messages];
    [fetchRequest setFetchLimit:30];
    [fetchRequest setFetchOffset:page * 30];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return [CHMessage MR_executeFetchRequest:fetchRequest inContext:context];
}








































































/*
- (void)viewDidLoad;
{
    [super viewDidLoad];
    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"Messages"];
    
    self.view.backgroundColor = kLightBackgroundColor;
    self.messageTable.backgroundColor = kLightBackgroundColor;
    
    self.shouldSlide = YES;
    self.keyboardIsVisible = NO;
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
    
    
    self.keyboardIsVisible = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    self.textView.text = self.group.unsentText;
    [self setSendButtonEnabled:[self canSendMessage]];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    self.group.unsentText = self.textView.text;
    self.beingDismissed = YES;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.keyboardIsVisible = YES;
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
    if (self.beingDismissed) {
        return;
    }
    self.heightOfKeyboard = 0;
    self.keyboardIsVisible = NO;
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
    if( self.keyboardIsVisible ) {
        [self.textView setKeyboardType:UIKeyboardTypeDefault];
        [self.textView resignFirstResponder];
        [self.textView becomeFirstResponder];
    }
    
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

- (void)imageTapped:(UIImage *)image;
{
    if (!image) {
        return;
    }
    
    self.mediaFocus = [[URBMediaFocusViewController alloc] init];
    [self.mediaFocus showImage:image fromView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self resignTextView];
}

//
// Sets the insets just how we want them, with whatever distance from the
// bottom of the screen (which will change, depending on the height of the textview,
// and if the keyboard is up.
//
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([segue.identifier isEqualToString:@"pushCHMessageDetailTableViewController"]) {
        CHMessageDetailTableViewController *dest = segue.destinationViewController;
        dest.group = self.group;
    }
}

#pragma mark - Camera

-(void)loadCamera;
{
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
 */

@end
