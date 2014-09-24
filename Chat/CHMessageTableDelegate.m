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
#import "CHMessageViewController.h"


NSString *const CHMesssageCellIdentifier = @"CHMessageTableViewCell";
NSString *const CHOwnMesssageCellIdentifier = @"CHOwnMessageTableViewCell";

@interface CHMessageTableDelegate ()

@property (atomic, copy) NSArray *messageIDs;
@property (nonatomic, assign) NSInteger page;
@property (atomic, assign) BOOL isFetching;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) void (^loadInNewMessages)(NSArray *messageIDs);

@end

@implementation CHMessageTableDelegate

#pragma mark - UITableView Datasource

- (instancetype)initWithTable:(UITableView *)table group:(CHGroup *)group;
{
    self = [super init];
    if (self) {
        _page = 0;
        _group = group;
        self.tableView = table;
        _isFetching = NO;
        self.messages = [NSMutableOrderedSet orderedSet];
        __weak CHMessageTableDelegate *this = self;
        self.loadInNewMessages = ^(NSArray *messageIDs) {
            __strong CHMessageTableDelegate *strongSelf = this;
            if(strongSelf) {
                this.messageIDs = messageIDs;
                @synchronized(this) {
                    for (NSManagedObjectID *anID in this.messageIDs) {
                        
                        CHMessage *message = [CHMessage objectID:anID toContext:[NSManagedObjectContext MR_defaultContext]];
                        if (message) {
                            [this.messages addObject:message];
                        }
                    }
                    this.messageIDs = nil;
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
                [this.messages sortUsingDescriptors:@[sortDescriptor]];
                [this reload:YES withScroll:YES animated:YES];
            }
        };
        
        self.refresh = [[UIRefreshControl alloc] init];
        [self.refresh addTarget:self
                         action:@selector(shouldRefresh:)
               forControlEvents:UIControlEventValueChanged];
        
        [table addSubview:self.refresh];
        table.dataSource = self;
        table.delegate = self;
        [self shouldRefresh:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessageNotification:)
                                                     name:kNewMessageReceivedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMostRecentMessages:)
                                                     name:kReloadActiveGroupNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    NSMutableArray *usernames = [NSMutableArray array];
    NSArray *activeMembers = self.group.members.array;
    for (CHUser *user in activeMembers) {
        [usernames addObject:user.username];
    }
    return [NSString stringWithFormat:@"To: %@", [usernames componentsJoinedByString:@", "]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
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

- (void)reload:(BOOL)reload withScroll:(BOOL)scroll animated:(BOOL)animated;
{
    if (reload) {
        [self.tableView reloadData];
    }
    if (scroll) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath
                                                indexPathForRow:([self tableView:self.tableView numberOfRowsInSection:0] - 1) inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}


#pragma mark - Getting Messages

- (void)shouldRefresh:(UIRefreshControl *)sender;
{
    self.isFetching = YES;
    [self messagesAtPage:_page]
    .then(_loadInNewMessages)
    .catch(^(NSError *error) {
        DLog(@"Error: %@", error);
    }).finally(^{
        self.page++;
        [self.refresh endRefreshing];
    });
}

- (void)getMostRecentMessages:(NSNotification *)note;
{
    id q = [CHBackgroundContext backgroundContext].queue;
    NSManagedObjectContext *context = [CHBackgroundContext backgroundContext].context;
    
    dispatch_promise_on(q, ^{
        return [self.group remoteMessagesAtPage:0];
    })
    .thenOn(q, ^{
        [context reset];
        NSArray *final = [self localMessagesAtPage:0 context:context];
        NSMutableArray *newMessageIDS = [NSMutableArray array];
        for (CHMessage *message in final) {
            [newMessageIDS addObject:message.actualObjectId];
        }
        return newMessageIDS;
    })
    .then(_loadInNewMessages);
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

#pragma mark Socket.io

- (void)newMessageNotification:(NSNotification *)note;
{
    CHMessage *message = note.userInfo[CHNotificationPayloadKey];
    if (message && [message.group isEqual:self.group]) {
        [self addMessage:message];
    } else if (message && [self.delegate respondsToSelector:@selector(otherGroupMessage:)]) {
        [self.delegate otherGroupMessage:message];
    }
}

- (void)addMessage:(CHMessage *)foreignMessage;
{
    [self.tableView beginUpdates];
    
    CHMessage *message = [CHMessage object:foreignMessage toContext:[NSManagedObjectContext MR_defaultContext]];
    if (message) {
        [self.messages addObject:message];
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView endUpdates];
    [self reload:NO withScroll:YES animated:YES];
}




@end
