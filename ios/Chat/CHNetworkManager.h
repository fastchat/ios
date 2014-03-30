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

    @property NSString *sessiontoken;

    // This needs to be moved...
    @property (strong, nonatomic) CHUser *currentUser;

-(void)postLoginWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(bool successful, NSError *error))callback;
-(void)logoutWithCallback: (void (^)(bool successful, NSError *error))callback;
- (void)registerWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
- (void)getGroups: (void (^)(NSArray *groups))callback;
- (void)createGroupWithName: (NSString *)groupName callback: (void (^)(bool successful, NSError *error))callback;
- (void)getMessagesFromDate: (NSDate *)date group:(NSString *)group callback:(void (^)(NSArray *messages))callback;
- (void)getProfile: (void (^)(CHUser *userProfile))callback;
- (void)getProfileOfUser: (NSString *)username callback: (void (^)(CHUser *userProfile))callback;
- (void)sendInviteToUsers: (NSArray *)invitees groupId: (NSString *) groupId callback: (void (^)(bool successful, NSError *error))callback;
- (void)acceptInviteAtIndex: (NSNumber *)index callback: (void (^)(bool successful, NSError *error))callback;
- (void)postDeviceToken:(NSData *)token callback:(void (^)(BOOL success, NSError *error))callback;

- (BOOL)hasStoredSessionToken;

+ (CHNetworkManager *)sharedManager;

@end

