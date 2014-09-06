//
//  CHBackgroundContext.m
//  Chat
//
//  Created by Ethan Mick on 9/3/14.
//
//

#import "CHBackgroundContext.h"

@interface CHBackgroundContext()

@end

@implementation CHBackgroundContext

+ (instancetype)backgroundContext;
{
    static CHBackgroundContext *_backgroundContext;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _backgroundContext = [[CHBackgroundContext alloc] init];
    });
    
    return _backgroundContext;
}

- (instancetype)init;
{
    if ( (self = [super init]) ) {
        
    }
    return self;
}

- (PMKPromise *)start;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        _queue = dispatch_queue_create("BackgroundQueue", 0);
        dispatch_async(_queue, ^{
            _context = [NSManagedObjectContext MR_context];
            fulfiller(self);
        });
    }];
    
}


@end
