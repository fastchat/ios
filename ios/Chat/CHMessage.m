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
            NSLog(@"Background save of image downloaded. Success?: %@", success ? @"YES" : @"NO");
        }];
        return image;
    });
}

- (void)setAuthorId:(NSString *)authorId;
{
    [self setPrimitiveAuthorId:authorId];
    [self setPrimitiveAuthor:[CHUser MR_findFirstByAttribute:CORE_DATA_ID withValue:authorId]];
}

- (void)setGroupId:(NSString *)groupId;
{
    [self setPrimitiveGroup:[CHGroup MR_findFirstByAttribute:CORE_DATA_ID withValue:groupId]];
}

@end
