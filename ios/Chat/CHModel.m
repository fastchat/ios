//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHModel.h"
#import "Mantle.h"


@interface CHModel ()

// Private interface goes here.

@end


@implementation CHModel

+ (instancetype)objectFromJSON:(NSDictionary *)dict;
{
    NSError *error = nil;
    MTLModel<MTLManagedObjectSerializing> *object = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dict error:&error];
    if (error) {
        DLog(@"Error Creating Object: %@", error);
    }
    
    error = nil;
    id finalObject = [MTLManagedObjectAdapter managedObjectFromModel:object
                                                insertingIntoContext:[NSManagedObjectContext MR_defaultContext]
                                                               error:&error];
    
    if (error) {
        DLog(@"Error Creating Managed Object: %@", error);
    }
    
    return finalObject;
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
