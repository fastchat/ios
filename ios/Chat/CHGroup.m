//
//  CHGroup.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHGroup.h"
#import "CHUser.h"
#import "CHNetworkManager.h"
#import "CHMessage.h"

@interface CHGroup ()
@property (nonatomic, strong) NSMutableDictionary *allUsers;
@end

@implementation CHGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
{
    self = [super initWithDictionary:dictionary error:error];
    self.allUsers = [[NSMutableDictionary alloc] init];
    self.memberDict = [[NSMutableDictionary alloc] init];
    
    if (self) {
        
        for (CHUser *user in self.members) {
            self.allUsers[user.userId] = user.username;
            self.memberDict[user.userId] = user;
        }
        
        for (CHUser *user in self.pastMembers) {
            self.allUsers[user.userId] = user.username;
            if (!self.memberDict[user.userId]) {
                self.memberDict[user.userId] = user;
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

- (NSString *)getGroupName;
{
    if( self.groupName != nil && ![self.groupName isEqualToString:@""] ) {
        return self.groupName;
    }
    
    NSMutableString *nameFromMembers = [@"" mutableCopy];
    if( self.members.count == 1 ) {
        [nameFromMembers appendString:[NSString stringWithFormat:@"Empty chat!"]];
    }
    else if( self.members.count == 2 ) {
        if (((CHUser *)self.members[0]).userId == [[CHNetworkManager sharedManager] currentUser].userId) {
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
            
            if (![currMember.userId isEqualToString:currLoggedInUser.userId]) {
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

+ (MTLValueTransformer *)membersJSONTransformer;
{
    //return [MTLValueTransformer [CHFastChatObject objectsFromJSON:self.members]];

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *members) {
        return [CHUser objectsFromJSON:members];
    } reverseBlock:^id(NSArray *members) {
        return @[];
    }];
}

+ (MTLValueTransformer *)pastMembersJSONTransformer;
{
    //return [MTLValueTransformer [CHFastChatObject objectsFromJSON:self.members]];
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *pastMembers) {
        return [CHUser objectsFromJSON:pastMembers];
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


@end
