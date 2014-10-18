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
#import "CHMTLMessage.h"

@interface CHMTLGroup ()

@end

@implementation CHMTLGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
{
    self = [super initWithDictionary:dictionary error:error];

    if (self) {
        
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
{
    return @{
             @"pastMembers": @"leftMembers"
            };
}

+ (MTLValueTransformer *)membersJSONTransformer;
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *members) {
        return [CHMTLUser objectsFromJSON:members];
    } reverseBlock:^id(NSArray *members) {
        return @[];
    }];
}

+ (MTLValueTransformer *)pastMembersJSONTransformer;
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id (NSArray *pastMembers) {
        return [CHMTLUser objectsFromJSON:pastMembers];
    } reverseBlock:^id(NSArray *pastMembers) {
        return @[];
    }];
}

+ (MTLValueTransformer *)lastMessageJSONTransformer;
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *messageData) {
        if (messageData) {
            return [[CHMTLMessage objectsFromJSON:@[messageData]] lastObject];
        }
        return nil;
    } reverseBlock:^id(CHMTLMessage *lastMessage) {
        if (lastMessage) {
            [MTLJSONAdapter JSONDictionaryFromModel:lastMessage];
        }
        return nil;
    }];
}

#pragma mark - Core Data

+ (NSDictionary *)managedObjectKeysByPropertyKey;
{
    NSMutableDictionary *values = [[super managedObjectKeysByPropertyKey] mutableCopy];
    values[@"_id"] = @"chID";
    values[@"messages"] = [NSNull null];
    return values;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing;
{
    return [NSSet setWithObjects:@"_id", nil];
}


@end
