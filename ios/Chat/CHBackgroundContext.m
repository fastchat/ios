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
        _context = [NSManagedObjectContext MR_context];
    }
    return self;
}


@end
