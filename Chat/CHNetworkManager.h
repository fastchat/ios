//
//  CHNetworkManager.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "AFHTTPSessionManager.h"

@class CHUser, CHGroup, CHMessage;

@interface CHNetworkManager : AFHTTPSessionManager

#pragma mark - Init

+ (CHNetworkManager *)sharedManager;
- (void)setSessionToken:(NSString *)token;

#pragma mark - New Methods

- (PMKPromise *)registerWithUser:(CHUser *)user;
- (PMKPromise *)loginWithUser:(CHUser *)user;
- (PMKPromise *)currentUserProfile;
- (PMKPromise *)currentUserGroups;
- (PMKPromise *)logout:(BOOL)all;
- (PMKPromise *)avatarForUser:(CHUser *)user;
- (PMKPromise *)leaveGroup:(NSString *)groupId;
- (PMKPromise *)newGroupWithName:(id)name members:(NSArray *)members;
- (PMKPromise *)messagesForGroup:(CHGroup *)group page:(NSInteger)page;
- (PMKPromise *)postMediaMessageWithImage:(UIImage *)image
                                  groupId:(NSString *)groupId
                                  message:(NSString *)message;
- (PMKPromise *)mediaForMessage:(CHMessage *)message;
- (PMKPromise *)newUsers:(NSArray *)invitees forGroup:(CHGroup *)group;
- (PMKPromise *)newAvatar:(UIImage *)image forUser:(CHUser *)user;
- (PMKPromise *)postDeviceToken:(NSData *)token;


@end

