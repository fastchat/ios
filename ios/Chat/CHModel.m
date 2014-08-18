//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHModel.h"
#import "Mantle.h"

#define MTL_CLASS_PREFIX @"MTL"

@interface CHModel ()

// Private interface goes here.

@end


@implementation CHModel

+ (instancetype)objectFromJSON:(NSDictionary *)dict;
{
    NSString *className = NSStringFromClass([self class]);
    className = [className substringFromIndex:CLASS_PREFIX.length];
    className = [NSString stringWithFormat:@"%@%@%@", CLASS_PREFIX, MTL_CLASS_PREFIX, className];
    DLog(@"Class Name: %@", className);
    
    NSError *error = nil;
    MTLModel<MTLManagedObjectSerializing> *object = [MTLJSONAdapter modelOfClass:NSClassFromString(className) fromJSONDictionary:dict error:&error];
    if (error) {
        DLog(@"Error Creating Object: %@", error);
    }
    
    error = nil;
    if (object) {
        id finalObject = [MTLManagedObjectAdapter managedObjectFromModel:object
                                                    insertingIntoContext:[NSManagedObjectContext MR_defaultContext]
                                                                   error:&error];
        
        if (error) {
            DLog(@"Error Creating Managed Object: %@", error);
        }

        return finalObject;
    }
    
    return nil;
}

+ (NSArray *)objectsFromJSON:(NSArray *)array;
{
    NSMutableArray *created = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        
        id object = [self objectFromJSON:dict];
        
        if (object) {
            [created addObject:object];
        }
    }
    
    return created;
}

@end
