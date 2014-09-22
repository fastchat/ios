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
        CHModel *finalObject = [MTLManagedObjectAdapter managedObjectFromModel:object
                                                                  insertingIntoContext:context
                                                                                 error:&error];
        
        
        [finalObject createdFromMantle];
        
        if (error) {
            DLog(@"Error Creating Managed Object: %@", error);
        }
        
        if (justID) {
            return [finalObject actualObjectId];
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
    return dispatch_promise_on(CHBackgroundContext.backgroundContext.queue, ^{
        NSMutableArray *created = [NSMutableArray array];
        NSManagedObjectContext *context = CHBackgroundContext.backgroundContext.context;
        
        for (NSDictionary *dict in array) {
            CHModel *made = [self objectIDFromJSON:dict justID:NO context:context];
            if (made) {
                [created addObject:made];
            }
        }

        [context MR_saveToPersistentStoreAndWait];
        return created;
    });
}

- (void)createdFromMantle;
{
    
}

- (NSManagedObjectID *)actualObjectId;
{
    return [super objectID];
}

+ (instancetype)object:(NSManagedObject *)object toContext:(NSManagedObjectContext *)context;
{
    return [self objectID:object.objectID toContext:context];
}

+ (instancetype)objectID:(NSManagedObjectID *)anID toContext:(NSManagedObjectContext *)context;
{
    NSError *error = nil;
    CHModel *model = (CHModel *)[context existingObjectWithID:anID error:&error];
    if (error) {
        DLog(@"Error Fetching Object: %@", error);
    }
    return model;
}

@end
