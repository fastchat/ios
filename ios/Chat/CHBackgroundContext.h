//
//  CHBackgroundContext.h
//  Chat
//
//  Created by Ethan Mick on 9/3/14.
//
//

#import <Foundation/Foundation.h>

/**
 * With so many blocks, the background thread changes often.
 * This is the context that should be used on *all* background
 * threads.
 */
@interface CHBackgroundContext : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

+ (instancetype)backgroundContext;
- (PMKPromise *)start;

@end
