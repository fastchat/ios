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
             @"pastMembers": @"leftMembers"
    };
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

+ (NSDictionary *)managedObjectKeysByPropertyKey;
{
    NSMutableDictionary *values = [[super managedObjectKeysByPropertyKey] mutableCopy];
    values[@"_id"] = @"chID";
    values[@"memberDict"] = [NSNull null];
    values[@"lastMessage"] = [NSNull null];
    values[@"messages"] = [NSNull null];
    values[@"allUsers"] = [NSNull null];
    return values;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing;
{
    return [NSSet setWithObjects:@"_id", nil];
}


@end
