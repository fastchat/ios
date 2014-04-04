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
#import "CHNetworkManager.h"
#import "CHInviteUserViewController.h"
#import "CHUser.h"
#import "CHMessageTableViewController.h"
#import "CHMessageTableViewCell.h"
#import "CHOwnMessageTableViewCell.h"
#import "CHSocketManager.h"

@interface CHMessageViewController ()

@property NSString *messages;
@property NSMutableArray *messageArray;
@property (nonatomic, strong) SocketIO *socket;


@property NSMutableArray *messageAuthorsArray;
@property (nonatomic, strong) NSMutableDictionary *members;

@end

@implementation CHMessageViewController
    IBOutlet NSLayoutConstraint* _textViewSpaceToBottomConstraint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [self.messageTable setDelegate:self];
    [self.messageTable setDataSource:self];
    
    self.messages = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //[self.messageDisplayTextView setScrollsToTop:NO];
    
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
            [self.messageArray addObject:message[@"text"]];
            [self.messageAuthorsArray addObject:self.members[message[@"from"]]];
        }
        
        self.messageArray = [[[self.messageArray reverseObjectEnumerator] allObjects] mutableCopy];
        self.messageAuthorsArray = [[[self.messageAuthorsArray reverseObjectEnumerator] allObjects] mutableCopy];
        
        [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        [self.messageTable reloadData];
    }];
    
    [self.messageField becomeFirstResponder];
}

- (void) inviteUser;
{
    DLog(@"Displaying invite screen %@", self.groupId);
    CHInviteUserViewController *inviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHInviteUserViewController"];
    [inviteViewController setGroupId:self.groupId];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

/*- (void) socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error;
{
    DLog(@"Disconnected! %@ %@", socket, error);
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
{
    DLog(@"Messsage: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
{
    DLog(@"JSON: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
{
    DLog(@"RECEIVED AN EVENT RIGHT OVER HERE");
    DLog(@"Event: %@", packet.dataAsJSON);
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        
//            self.messageDisplayTextView.text = [NSString stringWithFormat:@"%@ %@\n%@: %@\n\n", self.messageDisplayTextView.text, [[NSDate alloc] initWithTimeIntervalSinceNow:0], data[@"from"], data[@"text"]];

        // Ensure only messages from the current group are used
//        if (self.groupId isEqualToString:packet.dataAsJSON[@"groupId"]) {
            [self.messageArray addObject:data[@"text"]];
      //  [_messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
            [self.messageAuthorsArray addObject:data[@"from"]];

//        [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];
            [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
            [self.messageTable reloadData];
    }

}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendButtonTouched:(id)sender {
    NSString *msg = self.messageField.text;
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    DLog(@"Curr user: %@", currUser.username);
    DLog(@"group: %@", self.groupId);
//    [_socket sendEvent:@"message" withData:@{@"from": currUser.userId, @"text" : msg, @"groupId": self.groupId}];

    [[CHSocketManager sharedManager] sendMessageWithEvent:@"message" data:@{@"from": currUser.userId, @"text" : msg, @"groupId": self.groupId}];
    
    self.messageField.text = @"";
    
//    [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_messageArray addObject:msg];
    [_messageAuthorsArray addObject:_members[currUser.userId]];

    [self.messageTable reloadData];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) keyboardWillShow: (NSNotification*) n
{
    NSValue* bv = n.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect br = [bv CGRectValue];
    
    _textViewSpaceToBottomConstraint.constant = br.size.height;

//    self.messageTextField.text = @"";
    self.messageField.text = @"";
}

- (void) keyboardWillHide: (NSNotification*) n
{
    _textViewSpaceToBottomConstraint.constant = 0;
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cHMessageTableViewCell = @"CHMessageTableViewCell";
    
    CHMessageTableViewCell *cell = nil;

     CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    
    
    DLog(@"messagesAuthorsArray: %@, currUser.userId: %@", _messageAuthorsArray[indexPath.row], currUser.userId );
    if( [_messageAuthorsArray[indexPath.row] isEqualToString:self.members[currUser.userId]] ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CHOwnMessageTableViewCell" forIndexPath:indexPath];
        cell.messageTextView.text = [self.messageArray objectAtIndex:indexPath.row];
        
    }
    
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cHMessageTableViewCell forIndexPath:indexPath];
        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"%@:",[self.messageAuthorsArray objectAtIndex:indexPath.row]];
        cell.messageTextView.text = [self.messageArray objectAtIndex:indexPath.row];

    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGSize renderedSize = [[self.messageArray objectAtIndex:indexPath.row] sizeWithFont: [UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    return renderedSize.height + 30.0;
}

-(BOOL)manager:(CHSocketManager *)manager doesCareAboutMessage:(NSDictionary *)message;
{
    if( [message[@"group"] isEqualToString:_groupId]) {
        [_messageArray addObject:message[@"text"]];

        [self.messageAuthorsArray addObject:self.members[message[@"from"]]];
        DLog(@"Author: %@", self.members[message[@"from"]]);
        //        [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];
        [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
        [self.messageTable reloadData];

        return YES;
    }
    return NO;
}

@end
