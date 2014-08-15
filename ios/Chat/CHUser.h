//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHUser.h"

@class PMKPromise;

@interface CHUser : _CHUser

+ (instancetype)currentUser;
- (PMKPromise *)remoteGroups;
- (PMKPromise *)avatar;
- (void)setAvatar:(UIImage *)avatar;

@end
