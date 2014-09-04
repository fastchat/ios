//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHModel.h"
#import "Mantle.h"
#import "CHBackgroundContext.h"

#define MTL_CLASS_PREFIX @"MTL"

@interface CHModel ()


@end


@implementation CHModel

+ (id)objectIDFromJSON:(NSDictionary *)dict justID:(BOOL)justID context:(NSManagedObjectContext *)context;
{
    NSString *className = NSStringFromClass([self class]);
    className = [className substringFromIndex:CLASS_PREFIX.length];
    className = [NSString stringWithFormat:@"%@%@%@", CLASS_PREFIX, MTL_CLASS_PREFIX, className];
    
    NSError *error = nil;
    MTLModel<MTLManagedObjectSerializing> *object = [MTLJSONAdapter modelOfClass:NSClassFromString(className) fromJSONDictionary:dict error:&error];
    if (error) {
        DLog(@"Error Creating Object: %@", error);
    }
    
    error = nil;
    if (object) {
        NSManagedObject *finalObject = [MTLManagedObjectAdapter managedObjectFromModel:object
                                                                  insertingIntoContext:context
                                                                                 error:&error];
        
        if (justID) {
            // Already in a background thread
            [context MR_saveToPersistentStoreAndWait];
        }
        
        if (error) {
            DLog(@"Error Creating Managed Object: %@", error);
        }
        
        if (justID) {
            return finalObject.objectID;
        } else {
            return finalObject;
        }
    }
    
    return nil;
}

+ (instancetype)objectFromJSON:(NSDictionary *)dict;
{
    return [self objectIDFromJSON:dict justID:NO context:[NSManagedObjectContext MR_defaultContext]];
}

+ (PMKPromise *)objectsFromJSON:(NSArray *)array;
{
    return dispatch_promise(^{
        NSMutableArray *created = [NSMutableArray array];
        NSManagedObjectContext *context = CHBackgroundContext.backgroundContext.context;
        
        [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSManagedObjectID *objectID = [self objectIDFromJSON:obj justID:YES context:context];
            if (objectID) {
                [created addObject:objectID];
            }
        }];
        return created;
    }).then(^(NSArray *ids){ //Main Thread!
        NSMutableArray *created = [NSMutableArray array];
        for (NSManagedObjectID *anID in ids) {
            [created addObject:[[NSManagedObjectContext MR_defaultContext] objectWithID:anID]];
        }
        return created;
    });
}

@end
