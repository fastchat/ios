//
//  CHMessageTableDelegate.m
//  Chat
//
//  Created by Ethan Mick on 9/18/14.
//
//

#import "CHMessageTableDelegate.h"
#import "CHMessageTableViewCell.h"
#import "CHUser.h"
#import "CHMessage.h"
#import "CHGroup.h"
#import "CHBackgroundContext.h"

NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageTableDelegate ()

@property (atomic, copy) NSArray *messageIDs;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UIRefreshControl *refresh;

@end

@implementation CHMessageTableDelegate

#pragma mark - UITableView Datasource

- (instancetype)initWithTable:(UITableView *)table;
{
    self = [super init];
    if (self) {
        _page = 0;
        
        self.refresh = [[UIRefreshControl alloc] init];
        [self.refresh addTarget:self
                         action:@selector(shouldRefresh:)
               forControlEvents:UIControlEventValueChanged];
        
        [table addSubview:self.refresh];
        
        table.delegate = self;
        table.dataSource = self;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
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
    
    return cell;
}

///
/// Set the section title to the names of the members in chat
///
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSArray *activeMembers = self.group.members.array;
    return [NSString stringWithFormat:@"To: %@", [activeMembers componentsJoinedByString:@", "]];
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

#pragma mark - Scrolling

- (void)shouldRefresh:(UIRefreshControl *)sender;
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (scrollView.contentOffset.y < 100) { //AND not fetching
        NSLog(@"Fetch more!");
    }
}

#pragma mark - Core Data Fetching

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

- (NSArray *)messages;
{
    NSPredicate *messages = [NSPredicate predicateWithFormat:@"SELF.group == %@ AND SELF.chID != nil", self.group];
    NSFetchRequest *fetchRequest = [CHMessage MR_requestAllWithPredicate:messages];
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    return [CHMessage MR_executeFetchRequest:fetchRequest inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (PMKPromise *)remoteMessages;
{
    id q = [CHBackgroundContext backgroundContext].queue;
    return dispatch_promise_on(q, ^{
        return [self.group remoteMessagesAtPage:self.page];
    }).thenOn(q, ^(NSArray *messages){
        NSMutableArray *ids = [NSMutableArray array];
        for (CHMessage *message in messages) {
            [ids addObject:message.actualObjectId];
        }
        self.messageIDs = ids;
    });
}




































@end
