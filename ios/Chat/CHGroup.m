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

- (NSString *)name;
{
    if( self.primitiveName.length != 0 ) {
        return self.primitiveName;
    }
    
    NSMutableString *nameFromMembers = [[NSMutableString alloc] init];
    if( self.members.count == 1 ) {
        [nameFromMembers appendString:[NSString stringWithFormat:@"Empty chat!"]];
    }
    else if( self.members.count == 2 ) {
        if (((CHUser *)self.members.firstObject).chID == [CHUser currentUser].chID) {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[1]).username]];
        }
        else {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[0]).username]];
        }
    } else {
        CHUser *currLoggedInUser = [CHUser currentUser];
        for (int i = 0; i < self.members.count; i++) {
            CHUser *currMember = self.members[i];
            
            if (![currMember.chID isEqualToString:currLoggedInUser.chID]) {
                if (i == self.members.count - 1) {
                    [nameFromMembers appendString:[NSString stringWithFormat:@"%@",((CHUser *)self.members[i]).username]];
                }
                else {
                    [nameFromMembers appendString:[NSString stringWithFormat:@"%@,",((CHUser *)self.members[i]).username]];
                }
            }
        }
    }
    return nameFromMembers;
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
