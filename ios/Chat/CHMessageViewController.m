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

#define kDefaultContentOffset 70

@interface CHMessageViewController ()

@property NSString *messages;
@property NSMutableArray *messageArray;
@property NSMutableArray *msgArray;
@property (nonatomic, strong) SocketIO *socket;
@property CGRect previousMessageTextViewRect;


@property NSMutableArray *messageAuthorsArray;
@property (nonatomic, strong) NSMutableDictionary *members;

@property float heightOfKeyboard;

@end

@implementation CHMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messageEntryField.hidden = YES;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    self.textView.maxHeight = 140.0f;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.placeholder = @"Send a message...";
    
    [self.view addSubview:self.containerView];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.containerView addSubview:imageView];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:entryImageView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //[UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.containerView.frame.size.width - 72, 1, 72, 40);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];//[UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
 	[self.containerView addSubview:doneBtn];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
   
    //Reload message table when app returns to foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:@"ReloadAppDelegateTable" object:nil];
    
    self.previousMessageTextViewRect = CGRectZero;
    
    // Set table view content offset
    self.messageTable.contentInset = UIEdgeInsetsMake(0, 0, kDefaultContentOffset, 0);
    
    
    [[CHSocketManager sharedManager] setDelegate:self];
    
    NSArray *members = _group[@"members"];
    NSMutableDictionary *tempIds = [NSMutableDictionary dictionary];
    [members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = obj;
        tempIds[dict[@"_id"]] = dict[@"username"];
    }];
    self.userIds = tempIds;
    
    _messageArray = [[NSMutableArray alloc] init];
    _messageAuthorsArray = [[NSMutableArray alloc] init];
    _msgArray = [[NSMutableArray alloc] init];
    
    self.messages = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(inviteUser)];
    self.navigationItem.rightBarButtonItem = inviteButton;
    
    //
    // make a memebrs hash
    //
    self.members = [NSMutableDictionary dictionary];
    for (NSDictionary *aMember in self.group[@"members"]) {
        self.members[aMember[@"_id"]] = aMember[@"username"];
    }
    
    
    ///
    /// Load up old messages
    ///
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.groupId callback:^(NSArray *messages) {
        
        for ( NSDictionary *message in messages) {
            DLog(@"MESSAGE: %@", message);
            
            [_msgArray addObject:message];
            [self.messageArray addObject:message[@"text"]];
            [self.messageAuthorsArray addObject:self.members[message[@"from"]]];
        }
        [[[self.msgArray reverseObjectEnumerator] allObjects] mutableCopy];
        self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];
        self.messageAuthorsArray = [[[self.messageAuthorsArray reverseObjectEnumerator] allObjects] mutableCopy];
        
        [self.messageTable reloadData];
        
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
    
}

-(void)resignTextView
{
	[self.textView resignFirstResponder];
}

- (void) inviteUser;
{
    CHInviteUserViewController *inviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHInviteUserViewController"];
    [inviteViewController setGroupId:self.groupId];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)sendMessage;
{
    
    NSString *msg = self.textView.text;
    
    if ( [msg isEqualToString:@""] || msg == nil ) {
        return;
    }
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    NSDictionary *data = @{@"from": currUser.userId, @"text" : msg, @"group": self.groupId};
    
    [[CHSocketManager sharedManager] sendMessageWithEvent:@"message" data:data];
    
    self.textView.text = @"";
    
    [self.messageTable beginUpdates];
    
    [_messageArray addObject:msg];
    [_messageAuthorsArray addObject:_members[currUser.userId]];
    
    // Magically add rows to table view
    [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.messageTable endUpdates];
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void) keyboardWillShow: (NSNotification*) notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnded = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameEndedRect = [keyboardFrameEnded CGRectValue];
    
    NSInteger keyboardHeight = keyboardFrameEndedRect.size.height;
    
    // Need to access keyboard height in textViewDidGrow. Using global for now, should refactor
    self.heightOfKeyboard = keyboardHeight;
    
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
  
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];

    
    
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView setAnimationCurve:animationCurve];
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect containerFrame = self.containerView.frame;
        self.messageTable.contentInset = UIEdgeInsetsMake(kDefaultContentOffset, 0, keyboardHeight+containerFrame.size.height, 0);
        self.messageTable.scrollIndicatorInsets = UIEdgeInsetsZero;
        
            [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        
        // set views with new info
        self.containerView.frame = containerFrame;
        
    }];

}

- (void) keyboardWillHide: (NSNotification*) notification
{
    
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView setAnimationCurve:animationCurve];
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect containerFrame = self.containerView.frame;
        self.messageTable.contentInset = UIEdgeInsetsMake(kDefaultContentOffset, 0, containerFrame.size.height, 0);
        self.messageTable.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        
        // set views with new info
        self.containerView.frame = containerFrame;

    }];
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cHMessageTableViewCell = @"CHMessageTableViewCell";
    
    CHMessageTableViewCell *cell = nil;

     CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    
    if( [_messageAuthorsArray[indexPath.row] isEqualToString:self.members[currUser.userId]] ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CHOwnMessageTableViewCell" forIndexPath:indexPath];
        // Setting to nil as workaround for iOS 7 bug showing links at wrong time
        cell.messageTextView.text = nil;
        [cell.messageTextView setScrollEnabled:NO];
        
        //Set attributed string as workaround for iOS 7 bug
        UIFont *font = [UIFont systemFontOfSize:14.0];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:font
                                    forKey:NSFontAttributeName];
        NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.messageArray objectAtIndex:indexPath.row]] attributes:attrsDictionary];
        
        cell.messageTextView.attributedText = attrString;//[self.messageArray objectAtIndex:indexPath.row];
        //cell.messageTextView.text = [self.messageArray objectAtIndex:indexPath.row];
        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"%@:",[self.messageAuthorsArray objectAtIndex:indexPath.row]];
        if ([[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"] != nil) {
            // Format the timestamp
            NSString *timestamp = [[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"];
            DLog(@"Timestamp: %@", timestamp);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
            NSDate *date  = [dateFormatter dateFromString:timestamp];
            DLog(@"date: %@", date);
            // Convert to new Date Format
            //            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *newDate = [dateFormatter stringFromDate:date];
            DLog(@"New date: %@", newDate);
            cell.timestampLabel.text = newDate;//[[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"];
        }
        else {
            cell.timestampLabel.text = @"";
        }

    }
    
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cHMessageTableViewCell forIndexPath:indexPath];
        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"%@:",[self.messageAuthorsArray objectAtIndex:indexPath.row]];
        // Setting to nil as workaround for iOS 7 bug showing links at wrong time
        cell.messageTextView.text = nil;
        [cell.messageTextView setScrollEnabled:NO];
        
        //Set attributed string as workaround for iOS 7 bug
        UIFont *font = [UIFont systemFontOfSize:14.0];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:font
                                    forKey:NSFontAttributeName];
        NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.messageArray objectAtIndex:indexPath.row]] attributes:attrsDictionary];
        
        cell.messageTextView.attributedText = attrString;
        
        if ([[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"] != nil) {
            // Format the timestamp
            NSString *timestamp = [[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"];
            DLog(@"Timestamp: %@", timestamp);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
            NSDate *date  = [dateFormatter dateFromString:timestamp];
            DLog(@"date: %@", date);
            // Convert to new Date Format
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *newDate = [dateFormatter stringFromDate:date];
            DLog(@"New date: %@", newDate);
            cell.timestampLabel.text = newDate;//[[_msgArray objectAtIndex:indexPath.row] objectForKey:@"sent"];
        }
        else {
            cell.timestampLabel.text = @"";
        }
        
        //cell.messageTextView.attributedText = [self.messageArray objectAtIndex:indexPath.row];
//        cell.messageTextView.text = [self.messageArray objectAtIndex:indexPath.row];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    DLog(@"Selected a row");
    [self resignTextView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGSize renderedSize = [[self.messageArray objectAtIndex:indexPath.row] sizeWithFont: [UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    return renderedSize.height + 30.0;
}

-(BOOL)manager:(CHSocketManager *)manager doesCareAboutMessage:(NSDictionary *)message;
{
    if( [message[@"group"] isEqualToString:_groupId]) {
        
        
        [self.messageTable beginUpdates];
        
        [_messageArray addObject:message[@"text"]];
        [_messageAuthorsArray addObject:_members[message[@"from"]]];
        
        // Magically add rows to table view
        [self.messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.messageTable endUpdates];
        
        [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
        return YES;
    }
    return NO;
}

- (void)reloadTableViewData{

    ///
    /// Load up old messages
    ///
    [[CHNetworkManager sharedManager] getMessagesForGroup:self.groupId callback:^(NSArray *messages) {
        self.messageArray =nil;
        self.messageAuthorsArray = nil;
        
        self.messageArray = [[NSMutableArray alloc] init];
        self.messageAuthorsArray = [[NSMutableArray alloc] init];
        
        for ( NSDictionary *message in messages) {
            [self.messageArray addObject:message[@"text"]];
            [self.messageAuthorsArray addObject:self.members[message[@"from"]]];
        }
        
        self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];
        self.messageAuthorsArray = [[[self.messageAuthorsArray reverseObjectEnumerator] allObjects] mutableCopy];

        [self.messageTable reloadData];
    }];

}

-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.containerView.frame = r;

    
    // Resize table
    self.messageTable.contentInset = UIEdgeInsetsMake(kDefaultContentOffset, 0, self.containerView.frame.size.height + self.heightOfKeyboard, 0);
    self.messageTable.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [self.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messageArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
