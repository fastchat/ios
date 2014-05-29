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
#import "CHMediaMessageTableViewCell.h"
#import "CHMediaOwnTableViewCell.h"
#import "URBMediaFocusViewController.h"
#import "UIImage+ColorArt.h"

#define kDefaultContentOffset self.navigationController.navigationBar.frame.size.height + 20

@interface CHMessageViewController ()

@property (nonatomic, strong) URBMediaFocusViewController *mediaFocus;

@property NSString *messages;
@property NSMutableArray *messageArray;
@property (nonatomic, strong) SocketIO *socket;
@property CGRect previousMessageTextViewRect;
@property (nonatomic, strong) NSMutableDictionary *members;
@property float heightOfKeyboard;
@property int currPage;
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
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"Attach"] forState:UIControlStateNormal];
	cameraBtn.frame = CGRectMake(0, 0, 40, 40);
    cameraBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8); //UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    [cameraBtn addTarget:self action:@selector(loadCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:cameraBtn];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 3, 230, 42)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(49, 5, 0, 5);
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 4.0;
    self.textView.layer.masksToBounds = YES;
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    self.textView.maxHeight = 140.0f;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textView.font = [UIFont systemFontOfSize:14.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(55, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = @"Send FastChat";
    

    [self.view addSubview:self.containerView];
    

    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.containerView addSubview:self.textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem]; //[UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.containerView.frame.size.width - 42, 1, 42, 40);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Send" forState:UIControlStateNormal];

    [doneBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];

 	[self.containerView addSubview:doneBtn];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
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
    self.messages = @"";
    
    //
    // make a memebrs hash
    //
    self.members = [NSMutableDictionary dictionary];
    for (CHUser *aMember in self.group.members) {
        self.members[aMember.userId] = aMember.username;
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
    
    self.keyboardIsVisible = NO;
}

-(void)viewWillAppear:(BOOL)animated;
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:@"ReloadAppDelegateTable" object:nil];
    
    ///
    /// This all needs to be refactored. AKA, it should never happen
    ///8
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

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Message Methods

- (void)loadMoreMessages;
{
    self.currPage = self.currPage + 1;
    
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.group._id page:self.currPage callback:^(NSArray *messages) {
        messages = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
        NSRange range = NSMakeRange(0, messages.count);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        
#warning Do not use reload Data
        [self.messageArray insertObjects:messages atIndexes:indexSet];
        [self.messageTable reloadData];
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        [self.refresh endRefreshing];
    }];
}

- (void)resignTextView;
{
	[self.textView resignFirstResponder];
}


- (void)sendMessage;
{
    
    DLog(@"We should send message: %hhd", self.mediaWasAdded);
    NSString *msg = self.textView.text;
    
    if ( [msg isEqualToString:@""] || msg == nil ) {
        return;
    }
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:@{@"from": currUser.userId, @"text" : msg, @"group": self.group._id}];
    
    [[CHSocketManager sharedManager] sendMessageWithEvent:@"message" data:data];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSz";

    data[@"sent"] = [formatter stringFromDate:[NSDate date] ];

    CHMessage *newMessage = [[CHMessage objectsFromJSON:@[data]] firstObject];
    
    [self.messageArray addObject:newMessage];
    
    
    [self.messageTable beginUpdates];
    
    // Magically add rows to table view
    [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.messageTable endUpdates];
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.textView.text = @"";
    self.shouldSlide = NO;
    
    if( self.mediaWasAdded ) {
        [[CHNetworkManager sharedManager] postMediaMessageWithImage:self.media groupId:[self.group _id] message:self.textView.text callback:^(BOOL success, NSError *error) {
            if( success ) {
                DLog(@"Successful post!");
            }
            else {
                DLog(@"Error posting image");
            }
            //[self resignTextView];
        }];
    }

    if( self.keyboardIsVisible ) {
        [self.textView setKeyboardType:UIKeyboardTypeDefault];
        [self.textView resignFirstResponder];
        [self.textView becomeFirstResponder];
    }
    
    self.media = nil;
    self.mediaWasAdded = NO;

}

#pragma mark - Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)notification;
{
    CGFloat keyboardHeight = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.heightOfKeyboard = keyboardHeight;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:curve
                     animations:^{
                         [self setTableViewInsetsFromBottom:keyboardHeight];
                         
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
    self.heightOfKeyboard = 0;
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self setTableViewInsetsFromBottom:0];
                         
                         CGRect containerFrame = self.containerView.frame;
                         containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
                         self.containerView.frame = containerFrame;
                     } completion:nil];
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *cHMessageTableViewCell = @"CHMessageTableViewCell";
    CHMessage *currMessage = (CHMessage *)[self.messageArray objectAtIndex:indexPath.row];
    CHMessageTableViewCell *cell = nil;
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];

    if( [self.members[currMessage.author] isEqualToString:self.members[currUser.userId]] ) {
        if( [currMessage.hasMedia floatValue] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CHMediaOwnTableViewCell" forIndexPath:indexPath];
            
            if( currMessage.theMediaSent == nil ) {
                [((CHMediaMessageTableViewCell *)cell).mediaMessageImageView setImage:[UIImage imageNamed:@"inprogress.png"]];
                [[CHNetworkManager sharedManager] getMediaForMessage:currMessage._id groupId:self.group._id callback:^(UIImage *messageMedia) {

                    [currMessage setTheMediaSent:messageMedia];
                    [self.messageArray replaceObjectAtIndex:indexPath.row withObject:currMessage];
                    [ ((CHMediaMessageTableViewCell *)cell).mediaMessageImageView setImage:messageMedia];
                }];
            }
            else {
                [((CHMediaMessageTableViewCell *)cell).mediaMessageImageView setImage:currMessage.theMediaSent];
            }
            
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CHOwnMessageTableViewCell" forIndexPath:indexPath];
        }
        cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Setting to nil as workaround for iOS 7 bug showing links at wrong time
        cell.messageTextView.text = nil;
        [cell.messageTextView setScrollEnabled:NO];
        
        //Set attributed string as workaround for iOS 7 bug
        UIFont *font = [UIFont systemFontOfSize:14.0];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:font
                                    forKey:NSFontAttributeName];
         
         NSAttributedString *attrString =
         [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",currMessage.text] attributes:attrsDictionary];
        cell.messageTextView.attributedText = attrString;
        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"by %@",[self.group usernameFromId:currMessage.author]];

        if( [_group memberFromId:currMessage.author].avatar != nil ) {
            [cell.avatarImageView setImage:[_group memberFromId:currMessage.author].avatar];
        }
        else {
            [cell.avatarImageView setImage:[UIImage imageNamed:@"profile-dark.png"]];
        }
        
        if (currMessage.sent != nil) {
            // Format the timestamp
            cell.timestampLabel.text = [[self timestampFormatter] stringFromDate:currMessage.sent];
        }
        else {
            cell.timestampLabel.text = @"";
        }

    }
    
    else {
        if( [currMessage.hasMedia floatValue] ) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CHMediaMessageTableViewCell" forIndexPath:indexPath];
            
            [[CHNetworkManager sharedManager] getMediaForMessage:currMessage._id groupId:self.group._id callback:^(UIImage *messageMedia) {
                [ ((CHMediaMessageTableViewCell *)cell).mediaMessageImageView setImage:messageMedia];
            }];
            
            [((CHMediaMessageTableViewCell *)cell) setupGestureWithTableView:self];
            
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:cHMessageTableViewCell forIndexPath:indexPath];
        }

        cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;

        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"by %@", [self.group usernameFromId:currMessage.author]];
        // Setting to nil as workaround for iOS 7 bug showing links at wrong time
        cell.messageTextView.text = nil;
        [cell.messageTextView setScrollEnabled:NO];
        
        //Set attributed string as workaround for iOS 7 bug
        UIFont *font = [UIFont systemFontOfSize:14.0];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:font
                                    forKey:NSFontAttributeName];
        NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",currMessage.text] attributes:attrsDictionary];
        
        cell.messageTextView.attributedText = attrString;
       
        if ( [_group memberFromId:currMessage.author].avatar != nil) {
            UIImage *avatar = [_group memberFromId:currMessage.author].avatar;
            [cell.avatarImageView setImage:avatar];
            SLColorArt *colorArt = [avatar colorArt];
            cell.authorLabel.textColor = colorArt.primaryColor;
        }
        else {
            [cell.avatarImageView setImage:[UIImage imageNamed:@"profile-dark.png"]];
        }

        if (currMessage.sent != nil) {
            // Format the timestamp
            cell.timestampLabel.text = [[self timestampFormatter] stringFromDate:currMessage.sent];
        }
        else {
            cell.timestampLabel.text = @"";
        }
    }

    return cell;
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
    self.shouldSlide = YES;
    [self resignTextView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGSize renderedSize = [((CHMessage *)[self.messageArray objectAtIndex:indexPath.row]).text sizeWithFont: [UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    // Adding 45.0 to fix the bug where messages of certain lengths don't size the cell properly.
    if( [[[self.messageArray objectAtIndex:indexPath.row] hasMedia] floatValue]) {
        renderedSize.height += 110.0f;
    }
    return renderedSize.height + 45.0f;

}

- (BOOL)manager:(CHSocketManager *)manager doesCareAboutMessage:(CHMessage *)message;
{
    if( [message.group isEqualToString:self.group._id] ) {
        
        
        [self.messageTable beginUpdates];
       
        [self.messageArray addObject:message];
        
        // Magically add rows to table view
        [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.messageTable endUpdates];
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
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

    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
}

- (NSDateFormatter *)timestampFormatter;
{
    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    [timestampFormatter setDateStyle:NSDateFormatterLongStyle];
    timestampFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    timestampFormatter.dateFormat = @"MMMM dd, HH:mm";
    return timestampFormatter;
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
    self.media = image;
    
    self.shouldSlide = NO;

    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
       
    }];
    
    if( self.keyboardIsVisible ) {
        DLog(@"Keyboard should be visible");
    }
}


@end
