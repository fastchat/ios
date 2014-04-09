//
//  CHGroup.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHGroup.h"
#import "CHUser.h"

@interface CHGroup ()
@property (nonatomic, strong) NSMutableDictionary *allUsers;
@end

@implementation CHGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
{
    self = [super initWithDictionary:dictionary error:error];
    self.allUsers = [[NSMutableDictionary alloc] init];
    DLog(@"All users%@", self.pastMembers);
    if (self) {
        
        for (CHUser *user in self.members) {
            //DLog(@"dict: %@", dict);
            self.allUsers[user.userId] = user.username;
        }
        
        for (CHUser *user in self.pastMembers) {
            self.allUsers[user.userId] = user.username;
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
    for (int i = 0; i < self.members.count; i++) {
        [nameFromMembers appendString:[NSString stringWithFormat:@"%@,",((CHUser *)self.members[i]).username]];
    }
    return nameFromMembers;
}

- (NSString *)usernameFromId: (NSString *)theId;
{
    return self.allUsers[theId];
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


@end
