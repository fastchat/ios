//
//  CHUser.m
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import "CHUser.h"

@implementation CHUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
{
    return @{
             // Other attributes are mapped inheritently because they have the same name
             @"userId": @"_id"
             };
}

@end
