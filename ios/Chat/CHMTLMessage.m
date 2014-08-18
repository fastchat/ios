//
//  CHMessage.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHMTLMessage.h"
#import "CHGroup.h"

@implementation CHMTLMessage

+ (NSDictionary *)JSONKeyPathsByPropertyKey;
{
    return @{
             // Other attributes are mapped inheritently because they have the same name
             @"author": @"from"
             };
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSz";
    }
    return dateFormatter;
}

+ (NSValueTransformer *)sentJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

#pragma mark - Core Data

+ (NSDictionary *)managedObjectKeysByPropertyKey;
{
    NSMutableDictionary *values = [[super managedObjectKeysByPropertyKey] mutableCopy];
    values[@"_id"] = @"chID";
    values[@"author"] = @"authorId";
    values[@"group"] = @"groupId";
    return values;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing;
{
    return [NSSet setWithObjects:@"_id", nil];
}






@end
