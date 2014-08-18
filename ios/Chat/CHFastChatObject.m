//
//  CHFastChatObject.m
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHFastChatObject.h"
#import "Mantle/Mantle.h"

NSString *const CLASS_PREFIX_MANTLE = @"CHMTL";

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

#pragma mark - Managed Object Required Methods

+ (NSString *)managedObjectEntityName {
    NSString *className = NSStringFromClass(self);
    className = [className substringFromIndex:CLASS_PREFIX_MANTLE.length];
    return [NSString stringWithFormat:@"%@%@", CLASS_PREFIX, className];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{};
}

- (NSManagedObject *)managedObject;
{
    NSManagedObject *mob = [MTLManagedObjectAdapter managedObjectFromModel:self
                                                      insertingIntoContext:[NSManagedObjectContext MR_defaultContext]
                                                                     error:NULL];
    
    return mob;
    
}

@end
