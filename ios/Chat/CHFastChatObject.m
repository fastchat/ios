//
//  CHFastChatObject.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHFastChatObject.h"
#import "Mantle/Mantle.h"

@implementation CHFastChatObject

+ (NSArray *)objectsFromJSON:(NSArray *)array {
    NSMutableArray *created = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        
        NSError *error = nil;
        id object = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dict error:&error];
        if (error) {
            DLog(@"Error Creating Object: %@", error);
        }
        
        if (object) {
            [created addObject:object];
        }
    }
    
    return created;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ };
}

@end
