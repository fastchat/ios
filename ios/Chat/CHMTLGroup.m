//
//  CHGroup.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHMTLGroup.h"
#import "CHMTLUser.h"
#import "CHUser.h"
#import "CHNetworkManager.h"
#import "CHMessage.h"

@interface CHMTLGroup ()
@property (nonatomic, strong) NSMutableDictionary *allUsers;
@end

@implementation CHMTLGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
{
    self = [super initWithDictionary:dictionary error:error];
    self.allUsers = [[NSMutableDictionary alloc] init];
    self.memberDict = [[NSMutableDictionary alloc] init];
    
    if (self) {
        
        for (CHUser *user in self.members) {
            self.allUsers[user.chID] = user.username;
            self.memberDict[user.chID] = user;
        }
        
        for (CHUser *user in self.pastMembers) {
            self.allUsers[user.chID] = user.username;
            if (!self.memberDict[user.chID]) {
                self.memberDict[user.chID] = user;
            }
        }
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
{
    return @{
             // Other attributes are mapped inheritently because they have the same name
             @"groupName": @"name",
             @"pastMembers": @"leftMembers",
    };
}

- (NSString *)name;
{
    if( _name != nil && ![_name isEqualToString:@""] ) {
        return _name;
    }
    
    NSMutableString *nameFromMembers = [@"" mutableCopy];
    if( self.members.count == 1 ) {
        [nameFromMembers appendString:[NSString stringWithFormat:@"Empty chat!"]];
    }
    else if( self.members.count == 2 ) {
        if (((CHUser *)self.members[0]).chID == [[CHNetworkManager sharedManager] currentUser].chID) {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[1]).username]];
        }
        else {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[0]).username]];
        }
    }
    else {
        CHUser *currLoggedInUser = [[CHNetworkManager sharedManager] currentUser];
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

- (NSString *)usernameFromId: (NSString *)theId;
{
    return self.allUsers[theId];
}

- (CHUser *)memberFromId: (NSString *)theId;
{
    CHUser *userToReturn = nil;
 
    if (theId) {
        userToReturn = self.memberDict[theId];
    }
    
    return userToReturn;
}

- (BOOL)hasUnread;
{
    return self.unread.integerValue > 0;
}

+ (MTLValueTransformer *)membersJSONTransformer;
{
    //return [MTLValueTransformer [CHFastChatObject objectsFromJSON:self.members]];

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *members) {
        return [CHMTLUser objectsFromJSON:members];
    } reverseBlock:^id(NSArray *members) {
        return @[];
    }];
}

+ (MTLValueTransformer *)pastMembersJSONTransformer;
{
    //return [MTLValueTransformer [CHFastChatObject objectsFromJSON:self.members]];
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *pastMembers) {
        return [CHMTLUser objectsFromJSON:pastMembers];
    } reverseBlock:^id(NSArray *pastMembers) {
        return @[];
    }];
}

+ (MTLValueTransformer *)lastMessageJSONTransformer;
{
    return [MTLValueTransformer transformerWithBlock:^id (NSDictionary *messageData) {
        if (messageData) {
            return [[CHMessage objectsFromJSON:@[messageData]] lastObject];
        }
        return nil;
    }];
}

#pragma mark - Core Data

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSMutableDictionary *values = [[super managedObjectKeysByPropertyKey] mutableCopy];
    values[@"_id"] = @"groupId";
    return values;
}


+ (NSDictionary *)relationshipModelClassesByPropertyKey;
{
    return @{
             @"groupId" : @"_id"
            };
}


@end
