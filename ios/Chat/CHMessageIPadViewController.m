//
//  CHMessageIPadViewController.m
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import "CHMessageIPadViewController.h"
#import "CHNetworkManager.h"
#import "CHMessageFromTableViewCell.h"
#import "CHUser.h"
#import "SocketIOPacket.h"

@interface CHMessageIPadViewController ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) SocketIO *socket;

@end

@implementation CHMessageIPadViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.socket = [[SocketIO alloc] initWithDelegate:self];
    [_socket connectToHost:@"powerful-cliffs-9562.herokuapp.com" onPort:80 withParams:@{@"token": [CHNetworkManager sharedManager].sessiontoken}];
    
}

- (void)setGroup:(NSDictionary *)group;
{
    if (_group != group) {
        _group = group;
        self.title = group[@"name"];
        
        NSArray *members = _group[@"members"];
        NSMutableDictionary *tempIds = [NSMutableDictionary dictionary];
        [members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = obj;
            tempIds[dict[@"_id"]] = dict[@"username"];
        }];
        self.userIds = tempIds;
    
        ///
        /// Load up old messages
        ///
        [[CHNetworkManager sharedManager] getMessagesForGroup:_group[@"_id"] callback:^(NSArray *messages) {
            self.messages = [NSMutableArray arrayWithArray:[[messages reverseObjectEnumerator] allObjects]];
            [self.tableView reloadData];
            [self scrollToBottom];
        }];
        
        
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *message = _messages[indexPath.row];
    CHMessageFromTableViewCell *cell = nil;
    
    if ([message[@"from"] isEqualToString:_user.userId]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CHMessageToTableViewCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CHMessageFromTableViewCell" forIndexPath:indexPath];
    }
    
    cell.messageLabel.text = self.userIds[message[@"from"]];
    cell.messageImageView.image = nil;
    cell.messageTextView.text = message[@"text"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = self.messages[indexPath.row][@"text"];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 40;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSTimeInterval duration = [self keyboardAnimationDurationForNotification:notification];
    
    [UIView animateWithDuration:duration animations:^{
        self.bottomSpace.constant = size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, size.height + 60, 0);
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom;
{
    NSIndexPath *ipath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [self keyboardAnimationDurationForNotification:notification];
    
    [UIView animateWithDuration:duration animations:^{
        self.bottomSpace.constant = 0;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        [self.view layoutIfNeeded];
    }];
}

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

- (IBAction)sendTapped:(id)sender;
{
    NSString *msg = self.messageTextField.text;
    
    if (msg.length == 0) {
        return;
    }
    
    self.messageTextField.text = nil;
    
    CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    [_socket sendEvent:@"message" withData:@{@"from": currUser.username, @"text" : msg, @"groupId": self.group[@"_id"]}];

    [self.tableView beginUpdates];
    [self.messages addObject:@{@"from": currUser.userId, @"text": msg}];
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self scrollToBottom];
}

#pragma mark - Socket.io


- (void) socketIODidConnect:(SocketIO *)socket;
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
    DLog(@"Event: %@", packet.dataAsJSON);
    if ([packet.dataAsJSON[@"name"] isEqualToString:@"message"]) {
        NSDictionary *data = [packet.dataAsJSON[@"args"] firstObject];
        
        //            self.messageDisplayTextView.text = [NSString stringWithFormat:@"%@ %@\n%@: %@\n\n", self.messageDisplayTextView.text, [[NSDate alloc] initWithTimeIntervalSinceNow:0], data[@"from"], data[@"text"]];
        
        [self.tableView beginUpdates];
        [self.messages addObject:data];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self scrollToBottom];
    }
}



@end
