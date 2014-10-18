//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHMessage.h"

@interface CHMessage : _CHMessage

- (PMKPromise *)media;
- (PMKPromise *)addedContent;
- (PMKPromise *)mediaForURL:(NSURL *)url;
- (CHUser *)getAuthorNonRecursive;

@end
