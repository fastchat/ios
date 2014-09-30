//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHGroup.h"
#import "CHUser.h"
#import "CHMessage.h"
#import "CHNetworkManager.h"
#import "CHSocketManager.h"

static NSString *const MESSAGES_KEY = @"messages";

@interface CHGroup ()

@property (nonatomic, strong) NSMutableDictionary *allUsers;

@end


@implementation CHGroup

@synthesize allUsers = _allUsers;
@synthesize membersDict = _membersDict;

+ (PMKPromise *)groupWithName:(NSString *)name members:(NSArray *)members;
{
    return [[CHNetworkManager sharedManager] newGroupWithName:name members:members];
}

- (void)awakeFromFetch;
{
    [super awakeFromFetch];
    [self commonInit];
}

- (void)awakeFromInsert;
{
    [super awakeFromInsert];
    [self commonInit];
}

- (void)commonInit;
{
    self.allUsers = [NSMutableDictionary dictionary];
}

- (PMKPromise *)remoteMessagesAtPage:(NSInteger)page;
{
    return [[CHNetworkManager sharedManager] messagesForGroup:self page:page];
}

- (BOOL)isEmpty;
{
    return self.members.count == 1 && [((CHUser *)self.members[0]).chID isEqual:[CHUser currentUser].chID];
}

- (void)setTyping:(BOOL)typing;
{
    [[CHSocketManager sharedManager] sendTypingWithData:@{@"group": self.chID, @"typing": @(typing)}
                                        acknowledgement:nil];
}

- (NSString *)name;
{
    if( self.primitiveName.length != 0 ) {
        return self.primitiveName;
    }
    
    if( self.members.count == 1 ) {
        return @"Empty chat!";
    } else {
         NSMutableString *nameFromMembers = [[NSMutableString alloc] init];
        for (CHUser *user in self.members) {
            if ([user isEqual:[CHUser currentUser]]) {
                continue;
            }
            [nameFromMembers appendFormat:@"%@, ", user.username];
        }
        
        if ([[nameFromMembers substringFromIndex:nameFromMembers.length - 2] isEqualToString:@", "]) {
            return [nameFromMembers substringToIndex:nameFromMembers.length - 2];
        }
        return nameFromMembers;
    }
}

- (CHUser *)userFromID:(NSString *)anID;
{
    return self.membersDict[anID];
}

- (NSMutableDictionary *)membersDict;
{
    if (!_membersDict) {
        _membersDict = [NSMutableDictionary dictionary];
        for (CHUser *aUser in self.members) {
            _membersDict[aUser.chID] = aUser;
        }
        
        for (CHUser *aUser in self.pastMembers) {
            _membersDict[aUser.chID] = aUser;
        }
    }
    return _membersDict;
}

- (BOOL)hasUnread;
{
    return [self unreadValue] > 0;
}

- (void)unreadIncrement;
{
    [self setPrimitiveUnreadValue:[self primitiveUnreadValue] + 1];
}

+ (CHGroup *)groupForMessage:(CHMessage *)message;
{
    return [CHGroup MR_findFirstByAttribute:@"chID" withValue:message.group];
}

- (PMKPromise *)addUsers:(NSArray *)users;
{
    return [[CHNetworkManager sharedManager] newUsers:users forGroup:self];
}

#pragma mark - Core Data

- (void)addMessagesObject:(CHMessage *)value_;
{
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:MESSAGES_KEY]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:MESSAGES_KEY];
    [tmpOrderedSet addObject:value_];
    [self setPrimitiveValue:tmpOrderedSet forKey:MESSAGES_KEY];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:MESSAGES_KEY];
    
    ///
    /// After adding a message, also set it to the "last message" sent.
    ///
    [self setLastMessage:value_];
}

- (void)addMessages:(NSOrderedSet*)value_;
{
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:MESSAGES_KEY]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [value_ count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:MESSAGES_KEY];
        [tmpOrderedSet addObjectsFromArray:[value_ array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:MESSAGES_KEY];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:MESSAGES_KEY];
    }
}



@end
