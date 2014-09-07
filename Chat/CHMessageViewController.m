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

#define kDefaultContentOffset self.navigationController.navigationBar.frame.size.height + 20

NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) URBMediaFocusViewController *mediaFocus;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, assign) NSInteger currPage;
@property (nonatomic, strong) UIResponder *previousResponder;
@property (nonatomic, assign) BOOL beingDismissed;
@property (nonatomic, assign) CGFloat heightOfKeyboard;
@property (nonatomic, strong) UIRefreshControl *refresh;

@property (nonatomic, assign) BOOL shouldScroll;
@property (nonatomic, assign) BOOL shouldSlide;
@property (nonatomic, assign) BOOL keyboardIsVisible;
@property (nonatomic, assign) BOOL mediaWasAdded;
@property (nonatomic, strong) UIImage *media;

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
    
    self.currPage = 0;
    
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self
                     action:@selector(loadMoreMessages)
           forControlEvents:UIControlEventValueChanged];

    [self.messageTable addSubview:self.refresh];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.messageTable.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.containerView addSubview:line];
    
    //UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"Attach"] forState:UIControlStateNormal];
	cameraBtn.frame = CGRectMake(0, 0, 40, 40);
    cameraBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
    [cameraBtn addTarget:self action:@selector(loadCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:cameraBtn];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 2, 230, 36)];
    self.textView.isScrollable = NO;
//    self.textView.contentInset = UIEdgeInsetsMake(49, 5, 0, 5);
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
    
    ///
    /// Load up old messages
    ///
//TODO: background thread?
    DLog(@"Middle");
    NSPredicate *theseMessages = [NSPredicate predicateWithFormat:@"SELF.group == %@ AND SELF.chID != nil", self.group];
//    NSInteger count = [CHMessage MR_countOfEntitiesWithPredicate:theseMessages];
    
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CHMessage"];
//    [fetchRequest setFetchLimit:10];
//    [fetchRequest setFetchBatchSize:10];
//    [fetchRequest setFetchOffset:count - 10];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    [fetchRequest setPredicate:theseMessages];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:context
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:@"messageCache"];
    
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
    NSError *error;
    BOOL success = [controller performFetch:&error];
    if (!success || error) {
        DLog(@"What: %@", error);
    }
    DLog(@"End Middle");
    
    ///
    /// Load new messages, async
    ///
    dispatch_promise_on([CHBackgroundContext backgroundContext].queue, ^{
        return [self.group remoteMessagesAtPage:_currPage];
    }).then(^{
        [self reload:YES withScroll:YES animated:YES];
    });
    
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


    /// Using reloadMessages instead of reloadMessagesWithScroll because I haven't figured out how to make reloadMessagesWithScroll
    /// work when being called as the selector. This should be fixed eventually.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessages) name:@"ReloadActiveGroupNotification" object:nil];
    
    [self reload:NO withScroll:YES animated:NO];
    DLog(@"End");
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    [self reload:NO withScroll:YES animated:NO];
}

-(void)sendUserTypingAction;
{
    DLog(@"User changed text field");
}

- (NSMutableString *)trimString: (NSString *)stringToTrim;
{
    // Remove trailing ','
    NSMutableString *trimmedString = [[stringToTrim substringToIndex:stringToTrim.length - 2] mutableCopy];
    
    return trimmedString;
}

- (void)reloadMessages;
{
    ///
    /// Load up old messages
    ///
    [_group remoteMessagesAtPage:0].then(^{
        [self reload:YES withScroll:YES animated:YES];
    });
}

- (void)reload:(BOOL)reload withScroll:(BOOL)scroll animated:(BOOL)animated;
{
    if (reload) {
        [self.messageTable reloadData];
    }
    if (scroll) {
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                                   indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:animated];
    }
}

- (void)addRemoteMessage:(CHMessage *)message;
{
    [self reload:YES withScroll:YES animated:YES];
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
                                                                    indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
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
                                               indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
}

#pragma mark - Message Methods

- (void)loadMoreMessages;
{
    _currPage++;
    
    [_group remoteMessagesAtPage:_currPage].then(^{
        [self.refresh endRefreshing];
    });
}

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
    
    [user sendMessage:newMessage toGroup:self.group].then(^{
        [self endSendingMessage];
    }).catch(^(NSError *error) {
//TODO: Have an error state for messages.
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

#pragma mark - TableView

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.messageTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.messageTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.messageTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    DLog(@"Index Path: %@ %@", indexPath, newIndexPath);
    
    self.shouldScroll = NO;
    UITableView *tableView = self.messageTable;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
        {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            self.shouldScroll = YES;
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
{
    [self.messageTable endUpdates];
    [self reload:NO withScroll:_shouldScroll animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CHMessageTableViewCell *cell;
    
    UIColor *color = [UIColor whiteColor];
    
    CHUser *author = message.author;
    if ( [message.author isEqual:[CHUser currentUser]] ) {
        cell = [tableView dequeueReusableCellWithIdentifier:CHOwnMesssageCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CHMesssageCellIdentifier forIndexPath:indexPath];
        color = [UIColor blackColor];
    }
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: color,
                                 NSFontAttributeName: [UIFont systemFontOfSize:16.0]};
    cell.messageTextView.text = nil;
    cell.messageTextView.attributedText = nil;
    cell.messageTextView.attributedText = [[NSAttributedString alloc] initWithString:message.text ? message.text : @""
                                                                          attributes:attributes];
    cell.authorLabel.text = author.username;
    cell.timestampLabel.text = [self formatDate:message.sent];
    
    static UIImage *defaultImage = nil;
    if (!defaultImage) {
        defaultImage = [UIImage imageNamed:@"NoAvatar"];
    }
    
    cell.authorLabel.textColor = author.color;
    author.avatar.then(^(CHUser *user, UIImage *avatar){
        cell.avatarImageView.image = avatar;
    }).catch(^(NSError *error){
        cell.avatarImageView.image = defaultImage;
    });
    
    if (message.hasMediaValue) {
        message.media.then(^(UIImage *image){
            CGSize size = [self boundsForImage:image];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:message.text]];
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [string addAttributes:attributes range:NSMakeRange(0, string.length)];
            cell.messageTextView.attributedText = string;
        });
    }
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    cell.messageTextView.tag = indexPath.row;
    [cell.messageTextView addGestureRecognizer:tapper];
    
    return cell;
}

///
/// Set the section title to the names of the members in chat
///
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSMutableString *sectionTitle = @"To: ".mutableCopy;
    NSOrderedSet *activeMembers = self.group.members;

    for (CHUser *member in activeMembers) {
        [sectionTitle appendString:[NSMutableString stringWithFormat:@"%@, ", member.username]];
    }

    return [self trimString:sectionTitle];
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
    CHMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    
    self.shouldSlide = YES;
    [self resignTextView];
    
    if (message.hasMediaValue) {
        message.media.then(^(UIImage *image){
            [self expandImage:image];
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section;
{
    return 0;
}

/**
 * Let's help the tableview out some. Most people send 1 line messages, and that makes our
 * cells 49 pixels high.
 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (message.rowHeightValue > 0) {
        return message.rowHeightValue;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
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

    message.rowHeightValue = height;
    return height;
}

- (void)reloadTableViewData;
{
    ///
    /// Load up old messages
    ///
    [_group remoteMessagesAtPage:_currPage].then(^{
        [self.messageTable reloadData];
    });
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
                                                   indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
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

- (void)textViewTapped:(UITapGestureRecognizer *)sender;
{
    [self tableView:self.messageTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.view.tag inSection:0]];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;
{
    [self setSendButtonEnabled:[self canSendMessage]];
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
