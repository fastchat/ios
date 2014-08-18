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
#import "UIImage+ColorArt.h"
#import "HPTextViewInternal.h"

#define kDefaultContentOffset self.navigationController.navigationBar.frame.size.height + 20

NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageViewController ()

@property (nonatomic, strong) URBMediaFocusViewController *mediaFocus;
@property (nonatomic, strong) CHUser *currentUser;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, assign) NSInteger currPage;
@property (nonatomic, strong) UIResponder *previousResponder;
@property (nonatomic, assign) BOOL beingDismissed;


@property (nonatomic, strong) SocketIO *socket;
@property CGRect previousMessageTextViewRect;
@property (nonatomic, strong) NSMutableDictionary *members;
@property float heightOfKeyboard;

@property UIRefreshControl *refresh;
@property BOOL shouldSlide;
@property BOOL keyboardIsVisible;
@property BOOL mediaWasAdded;
@property UIImage *media;

@end

@implementation CHMessageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.view.backgroundColor = kLightBackgroundColor;
    self.messageTable.backgroundColor = kLightBackgroundColor;
    
    self.shouldSlide = YES;
    self.title = _group.groupName;
    self.messageEntryField.hidden = YES;
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
    
    self.previousMessageTextViewRect = CGRectZero;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                           0,
                                           self.containerView.frame.size.height,
                                           0);
    self.messageTable.contentInset = insets;
    self.messageTable.scrollIndicatorInsets = insets;
    
    ///
    /// Data
    ///
    [[CHSocketManager sharedManager] setDelegate:self];
    
    NSArray *members = _group.members;
    NSMutableDictionary *tempIds = [NSMutableDictionary dictionary];
    [members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CHUser *thisUser = obj;
        tempIds[thisUser.userId] = thisUser.username;
        
        
    }];
    
    self.userIds = tempIds;
    self.messageArray = [NSMutableArray array];
    
    //
    // make a memebrs hash
    //
    self.members = [NSMutableDictionary dictionary];
    for (CHUser *aMember in self.group.members) {
        ///
        /// Pre-load the colors of the Names
        ///
        UIImage *avatar = [_group memberFromId:aMember.username].avatar;
        NSMutableDictionary *nameAndColor = [NSMutableDictionary dictionary];
        
        if (avatar) {
            SLColorArt *colorArt = [avatar colorArt];
            nameAndColor[@"color"] = colorArt.primaryColor;
        }
        
        nameAndColor[@"username"] = aMember.username;
        self.members[aMember.userId] = nameAndColor;
    }
    
    self.mediaWasAdded = NO;
    
    ///
    /// Load up old messages
    ///
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.group._id page:0 callback:^(NSArray *messages) {
        if( messages ) {
            self.messageArray = [NSMutableArray arrayWithArray:messages];

            self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];
            [self.messageTable reloadData];
            [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }];

    /// Don't crash if we don't have messages pl0x
    /// I laughed out loud - EM
    if( !self.messageArray ) {
        self.messageArray = [NSMutableArray array];
    }
    
    self.currentUser = [[CHNetworkManager sharedManager] currentUser];
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

-(void)sendUserTypingAction;
{
    DLog(@"User changed text field");
}

///
/// Set the section title to the names of the members in chat
///
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSMutableString *sectionTitle = [@"To: " mutableCopy];
    DLog(@"Group id %@", self.group._id);
    NSArray *activeMembers = [[CHGroupsCollectionAccessor sharedAccessor] getActiveMembersForGroupWithId:self.group._id];

    for (CHUser *member in activeMembers) {
        [sectionTitle appendString:[NSMutableString stringWithFormat:@"%@, ", ((CHUser *)member).username]];
    }
    
    return [self trimString:sectionTitle];
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
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.group._id page:0 callback:^(NSArray *messages) {
        if( messages ) {
            self.messageArray = [NSMutableArray arrayWithArray:messages];
            
            self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];
            [self.messageTable reloadData];
            [self reloadMessagesWithScroll:YES];
        }
    }];
}

- (void)reloadMessagesWithScroll:(BOOL)shouldScroll;
{
    if( shouldScroll ) {
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


/*
 // I am sorry Mike. I tried. I really did. It's all sorts of fucked up.
- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated;
{
    [super beginAppearanceTransition:isAppearing animated:animated];
    
    if (!isAppearing) {
        _beingDismissed = YES;
    }
    
    if (isAppearing) {
        [self.transitionCoordinator animateAlongsideTransitionInView:nil animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            if (![context isCancelled]) {
                DLog(@"Showed successfully.");
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:@"ReloadAppDelegateTable" object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(keyboardWillShow:)
                                                             name:UIKeyboardWillShowNotification
                                                           object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(keyboardWillHide:)
                                                             name:UIKeyboardWillHideNotification
                                                           object:nil];
                
                ///
                /// This all needs to be refactored. AKA, it should never happen
                ///
                if (self.group == nil) {
                    [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
                        for (CHGroup *group in groups) {
                            if( [group._id isEqualToString:self.groupId] ) {
                                self.group = group;
                            }
                        }
                    }];
                }
                // Get all member avatars
                NSArray *members = _group.members;
                for( CHUser *user in members ) {
                    if( user.avatar == nil ) {
                        [[CHNetworkManager sharedManager] getAvatarOfUser:user.userId callback:^(UIImage *avatar) {
                            if( avatar ) {
                                user.avatar = avatar;
                                _group.memberDict[user.userId] = user;
                            }
                            else {
                                user.avatar = [UIImage imageNamed:@"profile-dark.png"];
                            }
                        }];
                    }
                }

            }
            
           
        }];
    } else if (!isAppearing && animated && self.previousResponder != nil) {
        UIView *keyboardView = self.previousResponder.inputAccessoryView.superview;
        if (!keyboardView) {
            [self.previousResponder becomeFirstResponder];
            keyboardView = self.previousResponder.inputAccessoryView.superview;
            if (!keyboardView) {
                return;
            } else {
                [self.previousResponder resignFirstResponder];
            }
        }
        
        [self.previousResponder becomeFirstResponder];
        [self.transitionCoordinator animateAlongsideTransitionInView:keyboardView animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            UIView* fromView = [[context viewControllerForKey:UITransitionContextFromViewControllerKey] view];
            CGRect endFrame = keyboardView.frame;
            endFrame.origin.x = fromView.frame.origin.x;
            keyboardView.frame = endFrame;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            
            if ([context isCancelled]) {
                _beingDismissed = NO;
                return;
            }
            
            DLog(@"FINISHED GONE");
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self.previousResponder resignFirstResponder];
            self.previousResponder = nil;
        }];
    }
}
*/

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];

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
                         [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
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
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:YES];
}

#pragma mark - Message Methods

- (void)loadMoreMessages;
{
    self.currPage = self.currPage + 1;
    
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.group._id page:self.currPage callback:^(NSArray *messages) {
        messages = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];

        NSInteger newCount = messages.count;
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = 0; i < newCount; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        NSRange range = NSMakeRange(0, messages.count);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];

        ///
        /// Actually add the rows animatedly
        ///
        [self.messageArray insertObjects:messages atIndexes:indexSet];
        [self.messageTable beginUpdates];
        [self.messageTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.messageTable endUpdates];
        
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_messageArray.count - newCount) inSection:0]
                                 atScrollPosition:UITableViewScrollPositionMiddle
                                         animated:NO];
        [self reloadMessagesWithScroll:NO];
        [self.refresh endRefreshing];
    }];
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
    
    self.progressBar.progress = 0.0;
//    self.progressBar.hidden = NO;
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:@{@"from": currUser.userId, @"text" : msg, @"group": self.group._id}];
    
    CHMessage *newMessage = [[CHMessage alloc] init];
    newMessage.text = self.textView.text;
    
    [_progressBar setProgress:0.5 animated:YES];
    if (self.textView.internalTextView.attachedImage) {
        newMessage.hasMedia = @YES;
        newMessage.theMediaSent = self.textView.internalTextView.attachedImage;
        [[CHNetworkManager sharedManager] postMediaMessageWithImage:self.textView.internalTextView.attachedImage
                                                            groupId:self.group._id
                                                            message:self.textView.text
                                                           callback:^(BOOL success, NSError *error) {
                                                               
                                                               self.textView.text = @"";
                                                               
                                                               [self.progressBar setProgress:1.0 animated:YES];
                                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                   self.progressBar.hidden = YES;
                                                               });
                                                               
                                                               if( success ) {
                                                                   DLog(@"Successful post!");
                                                               }
                                                               else {
                                                                   DLog(@"Error posting image");
                                                               }
                                                           }];
        
    } else {
        [[CHSocketManager sharedManager] sendMessageWithEvent:@"message" data:data acknowledgement:^(id argsData) {
            [self.progressBar setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressBar.hidden = YES;
            });
        }];
    }
    
    newMessage.author = currUser.userId;
    newMessage.group = _group._id;
    newMessage.sent = [NSDate date];
    
    [self addNewMessage:newMessage];
}

- (void)addNewMessage:(CHMessage *)message;
{
    [self.messageArray addObject:message];

    [self.messageTable beginUpdates];
    [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.messageTable endUpdates];
    

    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
    
    self.textView.text = @"";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = _messageArray[indexPath.row];
    CHMessageTableViewCell *cell;
    
    UIColor *color = [UIColor whiteColor];
    
    if ( [self.members[message.author][@"username"] isEqualToString:self.members[_currentUser.userId][@"username"]] ) {
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
    cell.authorLabel.text = [self.group usernameFromId:message.author];
    cell.timestampLabel.text = [self formatDate:message.sent];
    
    
    static UIImage *defaultImage = nil;
    if (!defaultImage) {
        defaultImage = [UIImage imageNamed:@"profile-dark.png"];
    }
    
    UIColor *nameColor = self.members[message.author][@"color"];
    if (nameColor) {
        cell.authorLabel.textColor = nameColor;
        [cell.avatarImageView setImage:[_group memberFromId:message.author].avatar];
    } else {
        [cell.avatarImageView setImage:defaultImage];
        cell.authorLabel.textColor = [UIColor blackColor];
    }
    
    if (message.hasMedia.boolValue) {
        [[CHNetworkManager sharedManager] getMediaForMessage:message._id groupId:self.group._id callback:^(UIImage *messageMedia) {
            [message setTheMediaSent:messageMedia];
            [self.messageArray replaceObjectAtIndex:indexPath.row withObject:message];
            
            CGSize size = [self boundsForImage:messageMedia];
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = messageMedia;
            textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:message.text]];
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
            [string addAttributes:attributes range:NSMakeRange(0, string.length)];
            cell.messageTextView.attributedText = string;
        }];
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
    CHMessage *message = _messageArray[indexPath.row];
    
    self.shouldSlide = YES;
    [self resignTextView];
    
    if (message.hasMedia.boolValue) {
        [self expandImage:message.theMediaSent];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CHMessage *message = _messageArray[indexPath.row];
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

- (BOOL)manager:(CHSocketManager *)manager doesCareAboutMessage:(CHMessage *)message;
{
    if( [message.group isEqualToString:self.group._id] ) {
        
        
        [self.messageTable beginUpdates];
       
        [self.messageArray addObject:message];
        
        // Magically add rows to table view
        [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.messageTable endUpdates];

        /// We are checking to see if the last added row is in the screen (most recent message). If it is, we assume that
        /// the user is not scrolling and auto-scroll to the bottom. Otherwise, don't touch anything and allow user to continue
        /// scrolling
        if ([[self.messageTable indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]]) {
            [self reloadMessagesWithScroll:YES];
        }
    
        return YES;
    }
    return NO;
}

- (void)reloadTableViewData;
{
    ///
    /// Load up old messages
    ///
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.group._id page:_currPage callback:^(NSArray *messages) {
        self.messageArray = nil;
        self.messageArray = [[NSMutableArray alloc] init];
        
        for ( CHMessage *message in messages) {
            [self.messageArray addObject:message];
        }
        
        self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];

        [self.messageTable reloadData];
    }];

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

    if (_messageArray.count > 0) {
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
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
