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
#import "CHGroupsCollectionAccessor.h"
#import "CHMessage.h"
#import "CHCircleImageView.h"
#import "URBMediaFocusViewController.h"
#import "HPTextViewInternal.h"

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
    self.view.backgroundColor = kLightBackgroundColor;
    self.messageTable.backgroundColor = kLightBackgroundColor;
    
    self.shouldSlide = YES;
    self.title = _group.name;
    _beingDismissed = NO;
    
    self.currPage = 0;
    
    self.refresh = [[UIRefreshControl alloc] init];
    self.refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to load old messages"];
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
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CHMessage"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"SELF.group == %@", self.group]];
    
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
    
    ///
    /// Scroll to bottom
    ///
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                               indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:NO];
    
    ///
    /// Load new messages
    ///
    [self.group remoteMessagesAtPage:_currPage].then(^{
        [self reloadTableWithScroll:YES animated:YES];
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
}

- (void)viewWillLayoutSubviews;
{
    [super viewWillLayoutSubviews];
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                               indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:NO];
}

-(void)sendUserTypingAction;
{
    DLog(@"User changed text field");
}

#warning FIX THIS
///
/// Set the section title to the names of the members in chat
///
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
//{
//    NSMutableString *sectionTitle = [@"To: " mutableCopy];
//    DLog(@"Group id %@", self.group._id);
//    NSArray *activeMembers = [[CHGroupsCollectionAccessor sharedAccessor] getActiveMembersForGroupWithId:self.group._id];
//
//    for (CHUser *member in activeMembers) {
//        [sectionTitle appendString:[NSMutableString stringWithFormat:@"%@, ", ((CHUser *)member).username]];
//    }
//    
//    return [self trimString:sectionTitle];
//}

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
        [self reloadTableWithScroll:YES animated:YES];
    });
}

- (void)reloadTableWithScroll:(BOOL)scroll animated:(BOOL)animated;
{
    [self.messageTable reloadData];
    if (scroll) {
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath
                                                   indexPathForRow:([self tableView:self.messageTable numberOfRowsInSection:0] - 1) inSection:0]
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:animated];
    }
}

- (void)addRemoteMessage:(CHMessage *)message;
{
    [self reloadTableWithScroll:YES animated:YES];
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
    
    [self addNewMessage:newMessage];
    
    [user sendMessage:newMessage toGroup:self.group].then(^{
        //update progress bar?
    });
    
    [self addNewMessage:newMessage];
    self.textView.text = @"";
}

- (void)addNewMessage:(CHMessage *)message;
{
    [self reloadTableWithScroll:YES animated:YES];
    
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
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.messageTable;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //probably don't need.
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.messageTable endUpdates];
    [self reloadTableWithScroll:YES animated:YES];
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
        defaultImage = [UIImage imageNamed:@"profile-dark.png"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGRect rect = [message.text boundingRectWithSize:CGSizeMake(205 - 16, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                             context:nil];

    
    CGFloat height = rect.size.height;
    // Adding 45.0 to fix the bug where messages of certain lengths don't size the cell properly.
    if( message.hasMedia.boolValue) {
        height += 150.0f;
    }
    return height + 45.0f;

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

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
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


@end
