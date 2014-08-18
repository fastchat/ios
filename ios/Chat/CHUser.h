//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHUser.h"

@class PMKPromise;

@interface CHUser : _CHUser

@property (nonatomic, copy) NSString *password;

+ (instancetype)currentUser;
+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password;
- (PMKPromise *)login;
- (BOOL)isLoggedIn;


- (PMKPromise *)remoteGroups;
- (PMKPromise *)leaveGroupAtIndex:(NSUInteger)index;
- (PMKPromise *)avatar;
- (void)setAvatar:(UIImage *)avatar;

@end
