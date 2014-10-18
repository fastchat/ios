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

@property (nonatomic, strong) UIImage *urlImage;

@end


@implementation CHMessage

@synthesize urlImage;

- (PMKPromise *)media;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (self.theMediaSent) {
            fulfill(self.theMediaSent);
            return;
        }
        if (self.urlImage) {
            fulfill(self.urlImage);
            return;
        }
        
        if (!self.hasMediaValue) {
            reject(nil);
        }
        
        fulfill([[CHNetworkManager sharedManager] mediaForMessage:self].then(^(UIImage *image){
            self.theMediaSent = image;
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                DLog(@"Background save of image downloaded. Success?: %@ %@", success ? @"YES" : @"NO", error);
            }];
            return image;
        }));
        

    }];
    
    
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

- (PMKPromise *)addedContent;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
        for (NSTextCheckingResult *match in matches) {
            DLog(@"MATCH %@", match);
            if ([match resultType] == NSTextCheckingTypeLink) {
                fulfill([self mediaForURL:match.URL]);
                return;
            }
        }
        reject(nil);
    }];
}

- (PMKPromise *)mediaForURL:(NSURL *)url;
{
    return [[CHNetworkManager sharedManager] imageFromURL:url].then(^(UIImage *image){
        self.urlImage = image;
        return image;
    });
}

@end
