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
- (PMKPromise *)logout;
- (PMKPromise *)avatarForUser:(CHUser *)user;
- (PMKPromise *)leaveGroup:(NSString *)groupId;
- (PMKPromise *)newGroupWithName:(id)name members:(NSArray *)members;
- (PMKPromise *)messagesForGroup:(CHGroup *)group page:(NSInteger)page;
- (PMKPromise *)postMediaMessageWithImage:(UIImage *)image
                                  groupId:(NSString *)groupId
                                  message:(NSString *)message;
- (PMKPromise *)mediaForMessage:(CHMessage *)message;

#pragma mark - Old Method

- (void)pushNewAvatarForUser: (NSString *)userId avatarImage: (UIImage *)avatarImage callback: (void (^)(bool successful, NSError *error))callback;
- (void)addNewUsers: (NSArray *)invitees groupId: (NSString *) groupId callback: (void (^)(bool successful, NSError *error))callback;
- (void)postDeviceToken:(NSData *)token callback:(void (^)(BOOL success, NSError *error))callback;



@end

