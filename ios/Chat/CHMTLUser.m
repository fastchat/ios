//
//  CHUser.m
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import "CHMTLUser.h"

@implementation CHMTLUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
{
    // Other attributes are mapped inheritently because they have the same name
    return @{
             @"userId": @"_id"
            };
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSMutableDictionary *values = [[super managedObjectKeysByPropertyKey] mutableCopy];
    
    return values;
}

@end
