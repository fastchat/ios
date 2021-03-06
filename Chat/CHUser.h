//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHUser.h"

@class CHMessage;

@interface CHUser : _CHUser

@property (nonatomic, copy) NSString *password;

+ (instancetype)currentUser;
+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password;
- (PMKPromise *)login;
- (PMKPromise *)registr; //not a spelling mistake, register is a protected word
- (PMKPromise *)profile;
- (PMKPromise *)logout:(BOOL)all;
- (BOOL)isLoggedIn;
- (UIColor *)color;

- (PMKPromise *)promiseDoNotDisturb:(BOOL)value;
- (PMKPromise *)remoteGroups;
- (PMKPromise *)leaveGroupAtIndex:(NSUInteger)index;
- (PMKPromise *)avatar;
- (PMKPromise *)avatar:(UIImage *)image;
- (PMKPromise *)sendMessage:(CHMessage *)message toGroup:(CHGroup *)group;
- (void)setAvatar:(UIImage *)avatar;

@end
