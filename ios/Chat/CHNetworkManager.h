//
//  CHNetworkManager.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "AFHTTPSessionManager.h"

@class CHUser;

@interface CHNetworkManager : AFHTTPSessionManager

#pragma mark - Init

+ (CHNetworkManager *)sharedManager;
- (void)setSessionToken:(NSString *)token;

#pragma mark - New Methods

- (PMKPromise *)loginWithUser:(CHUser *)user;
- (PMKPromise *)currentUserProfile;
- (PMKPromise *)currentUserGroups;
- (PMKPromise *)logout;
- (PMKPromise *)avatarForUser:(CHUser *)user;
- (PMKPromise *)leaveGroup:(NSString *)groupId;

#pragma mark - Old Method

- (void)registerWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
- (void)getGroups: (void (^)(NSArray *groups))callback;
- (void)createGroupWithName: (NSString *)groupName members: (NSArray *)members callback: (void (^)(bool successful, NSError *error))callback;
- (void)getMediaForMessage:(NSString *)messageId groupId:(NSString *)groupId callback:(void (^)(UIImage *messageMedia))callback;
- (void)getMessagesForGroup:(NSString *)group page:(NSInteger)page callback:(void (^)(NSArray *messages))callback;

- (void)pushNewAvatarForUser: (NSString *)userId avatarImage: (UIImage *)avatarImage callback: (void (^)(bool successful, NSError *error))callback;
- (void)addNewUsers: (NSArray *)invitees groupId: (NSString *) groupId callback: (void (^)(bool successful, NSError *error))callback;
- (void)acceptInviteAtIndex: (NSNumber *)index callback: (void (^)(bool successful, NSError *error))callback;
- (void)postDeviceToken:(NSData *)token callback:(void (^)(BOOL success, NSError *error))callback;
- (void)postMediaMessageWithImage:(UIImage *)image groupId:(NSString *)groupId message:(NSString *)message callback:(void (^)(BOOL success, NSError *error))callback;



@end

