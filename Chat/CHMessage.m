//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHMessage.h"
#import "CHGroup.h"
#import "CHUser.h"
#import "CHNetworkManager.h"
#import "CHBackgroundContext.h"

@interface CHMessage ()

@end


@implementation CHMessage

- (PMKPromise *)media;
{
    if (self.theMediaSent) {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
            fulfiller(self.theMediaSent);
        }];
    }
    
    return [[CHNetworkManager sharedManager] mediaForMessage:self].then(^(UIImage *image){
        self.theMediaSent = image;
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            DLog(@"Background save of image downloaded. Success?: %@ %@", success ? @"YES" : @"NO", error);
        }];
        return image;
    });
}

- (void)setAuthorId:(NSString *)authorId;
{
    NSManagedObjectContext *context = [NSThread isMainThread] ? [NSManagedObjectContext MR_defaultContext] : CHBackgroundContext.backgroundContext.context;
    [self setPrimitiveAuthorId:authorId];
    CHUser *user = [CHUser MR_findFirstByAttribute:CORE_DATA_ID withValue:authorId inContext:context];
//    DLog(@"FAILED TO FIND USER: %@ %@ %@", self.text, self, user);
    [self setPrimitiveAuthor:user];
}

- (void)setGroupId:(NSString *)groupId;
{
    NSManagedObjectContext *context = [NSThread isMainThread] ? [NSManagedObjectContext MR_defaultContext] : CHBackgroundContext.backgroundContext.context;
    [self setPrimitiveGroup:[CHGroup MR_findFirstByAttribute:CORE_DATA_ID withValue:groupId inContext:context]];
}

- (CHUser *)getAuthorNonRecursive;
{
    CHUser *user = nil;
    if (self.author == nil) {
        NSManagedObjectContext *context = [NSThread isMainThread] ? [NSManagedObjectContext MR_defaultContext] : CHBackgroundContext.backgroundContext.context;
        user = [CHUser MR_findFirstByAttribute:CORE_DATA_ID withValue:self.authorId inContext:context];
        if (user) {
            [self willChangeValueForKey:@"author"];
            [self setPrimitiveValue:user forKey:@"author"];
            [self didChangeValueForKey:@"author"];
        }
    } else {
        user = self.author;
    }
    return user;
}

@end
