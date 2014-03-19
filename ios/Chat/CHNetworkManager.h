//
//  CHNetworkManager.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "AFHTTPSessionManager.h"

@interface CHNetworkManager : AFHTTPSessionManager

    @property NSString *sessiontoken;

-(void)postLoginWithEmail: (NSString *)email password:(NSString *)password callback:(void (^)(bool successful, NSError *error))callback;
- (void)getGroups: (void (^)(NSArray *groups))callback;
- (void)createGroupWithName: (NSString *)groupName callback: (void (^)(bool successful, NSError *error))callback;
- (void)getMessagesFromDate: (NSDate *)date group:(NSString *)group callback:(void (^)(NSArray *messages))callback;
- (BOOL)hasStoredSessionToken;

+ (CHNetworkManager *)sharedManager;

@end

