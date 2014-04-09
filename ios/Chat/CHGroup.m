//
//  CHGroup.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHGroup.h"
#import "CHUser.h"

@implementation CHGroup

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

+ (MTLValueTransformer *)membersJSONTransformer;
{
    //return [MTLValueTransformer [CHFastChatObject objectsFromJSON:self.members]];

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *members) {
        return [CHUser objectsFromJSON:members];
    } reverseBlock:^id(NSArray *members) {
        return @[];
    }];
}


@end
