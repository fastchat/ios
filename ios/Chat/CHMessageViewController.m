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
    
    ///
    /// Connect to server!
    ///
    self.socket = [[SocketIO alloc] initWithDelegate:self];
    
    [_socket connectToHost:@"powerful-cliffs-9562.herokuapp.com" onPort:80 withParams:@{@"token": [CHNetworkManager sharedManager].sessiontoken}];
    
    // Load previous messages

    /*[[CHNetworkManager sharedManager] getMessagesFromDate:[[NSDate alloc] initWithTimeIntervalSinceNow:0] group:nil  callback:^(NSArray *messages) {
        DLog(@"Returned: %@", messages);
    }];*/
    
    _messageArray = [[NSMutableArray alloc] init];
    _messageAuthorsArray = [[NSMutableArray alloc] init];
    [self.messageTable setDelegate:self];
    [self.messageTable setDataSource:self];
    /* _messageTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, 300, 200)];
    [self.messageTable registerClass:[CHMessageTableViewCell class] forCellReuseIdentifier:@"CHMessageTableViewCell"];
    
    [_messageTable setDelegate:self];
    [_messageTable setDataSource:self];
    
    
    
    [self.view addSubview:_messageTable];
     */
    

    
    /*
    _messageField = [[UITextField alloc] initWithFrame:CGRectMake(35, 275, 250, 35)];
    
    _messageField.textColor = [UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0];
    _messageField.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _messageField.backgroundColor=[UIColor blueColor];
    _messageField.text=@"Hello World";
    [_messageField setDelegate:self];
    [self.view addSubview:_messageField];
    */
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(sendButtonTouched:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Send Message" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 320.0, 160.0, 40.0);
    [self.view addSubview:button];
    
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
        /// Map them together
        /// "_id": "532f38fd53664a0200000001",
        /// "username": "ethan"
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

        [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        [self.messageTable reloadData];
    }];
}

- (void) inviteUser;
{
    DLog(@"Displaying invite screen %@", self.groupId);
    CHInviteUserViewController *inviteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CHInviteUserViewController"];
    [inviteViewController setGroupId:self.groupId];
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (void) socketIODidConnect:(SocketIO *)socket;
{
    DLog(@"Connected! %@", socket);
   // NSString *text = self.messageDisplayTextView.text;
//    text = [text stringByAppendingString:@"\nConnected\n"];
//    self.messageDisplayTextView.text = text;
    
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

        [self.messageArray addObject:data[@"text"]];
      //  [_messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
        [self.messageAuthorsArray addObject:data[@"from"]];

//        [self.messageDisplayTextView scrollRangeToVisible:NSMakeRange([self.messageDisplayTextView.text length], 0)];
        [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        
        [self.messageTable reloadData];
    }

}


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
    [_socket sendEvent:@"message" withData:@{@"from": currUser.username, @"text" : msg, @"groupId": self.groupId}];

    self.messageField.text = @"";
    
//    [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [self.messageTable setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_messageArray addObject:msg];
    [_messageAuthorsArray addObject:currUser.username];

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
    DLog(@"Cell row: %i", indexPath.row);
    static NSString *cellIdentifier = @"CHMessageTableViewCell";
    
    CHMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    //cell.authorLabel.text = _messageAuthorsArray[indexPath.row];
    //cell.messageLabel.text = _messageArray[indexPath.row];
    
     CHUser *currUser = [[CHNetworkManager sharedManager] currentUser];
    
    
    
    if( _messageAuthorsArray[indexPath.row] == currUser.username ) {
//    if( [cell.authorLabel.text])
        cell.authorLabel.text = @"";
        cell.messageLabel.text = [self.messageArray objectAtIndex:indexPath.row];
        cell.messageLabel.textAlignment = UITextLayoutDirectionRight;
       // CGRectMake(boundsX+50 ,20, 300, 25);
        //self.messageLabel.frame = frame;
//        cell.frame
        
        
       /* UILabel *lisnerMessage=[[UILabel alloc] init];
        lisnerMessage.backgroundColor = [UIColor clearColor];
        [lisnerMessage setFrame:cell.frame];
        lisnerMessage.numberOfLines=0;
        lisnerMessage.textAlignment=UITextLayoutDirectionRight;
        lisnerMessage.text=[self.messageArray objectAtIndex:indexPath.row];
        [cell.contentView addSubview:lisnerMessage];
        */
        
        
        
        
       // cell.messageLabel.frame = CGRectMake(;
//        cell.messageLabel.textAlignment = UITextLayoutDirectionRight;
    }
    
    else {
        cell.authorLabel.text = [[NSString alloc] initWithFormat:@"%@:",[self.messageAuthorsArray objectAtIndex:indexPath.row]];
        cell.messageLabel.text = [self.messageArray objectAtIndex:indexPath.row];
        /*
        UILabel *authMessage = [[UILabel alloc] init];
        authMessage.backgroundColor = [UIColor redColor];
        [authMessage setFrame:cell.frame];
        authMessage.numberOfLines = 0;
        authMessage.textAlignment = UITextLayoutDirectionLeft;
        authMessage.text = [[NSString alloc] initWithFormat:@"%@:", [self.messageAuthorsArray objectAtIndex:indexPath.row] ];
        [cell.contentView addSubview:authMessage];

        UILabel *lisnerMessage=[[UILabel alloc] init];
        lisnerMessage.backgroundColor = [UIColor clearColor];
        [lisnerMessage setFrame:cell.frame];
        lisnerMessage.numberOfLines=0;
        lisnerMessage.textAlignment=UITextLayoutDirectionRight;
        lisnerMessage.text=[self.messageArray objectAtIndex:indexPath.row];
        [cell.contentView addSubview:lisnerMessage];
         */
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGSize renderedSize = [[self.messageArray objectAtIndex:indexPath.row] sizeWithFont: [UIFont fontWithName:@"Times New Roman" size:17] constrainedToSize:CGSizeMake(300, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    if (renderedSize.height < 50.0) {
        return 50.0;
    }
    return renderedSize.height;
}

@end
