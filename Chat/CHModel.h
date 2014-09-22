//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//

#import "_CHModel.h"
#import "Mantle.h"

@interface CHModel : _CHModel

/**
 * Returns an instance of the class from a JSON dictionary.
 * This method does not save the object to the context. It creates the
 * object on the default context (Main Thread).
 */
+ (instancetype)objectFromJSON:(NSDictionary *)dict;

/**
 * This method returns a promise because it runs in a background thread. It creates a large
 * amount of objects, as well as looking up existing results in the background. Because of
 * this, we want it to work on a background thread.
 * It saves the objects on the background context as well.
 *
 */
+ (PMKPromise *)objectsFromJSON:(NSArray *)array;

- (void)createdFromMantle;

- (NSManagedObjectID *)actualObjectId;

+ (instancetype)object:(NSManagedObject *)object toContext:(NSManagedObjectContext *)context;
+ (instancetype)objectID:(NSManagedObjectID *)anID toContext:(NSManagedObjectContext *)context;

@end
