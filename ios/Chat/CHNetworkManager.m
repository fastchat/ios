//
//  CHNetworkManager.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHNetworkManager.h"
#import "CHUser.h"

//#define BASE_URL @"http://192.168.1.78:3000"
#define BASE_URL @"http://powerful-cliffs-9562.herokuapp.com:80"

@interface CHNetworkManager()

@end

@implementation CHNetworkManager

+ (CHNetworkManager *)sharedManager;
{
    static CHNetworkManager *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CHNetworkManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if( (self = [super initWithBaseURL:[NSURL URLWithString:BASE_URL]]) ) {

    }
    return self;
}

-(void)postLoginWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(bool successful, NSError *error))callback;
{
    [self POST:@"/login" parameters:@{@"username" : username, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            self.sessiontoken = responseObject[@"session-token"];
            [self.requestSerializer setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
            
            // Save the session token to avoid future login
            [[NSUserDefaults standardUserDefaults]
             setObject:self.sessiontoken forKey:@"session-token"];

            [self GET:@"/user" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if( callback ) {
                    CHUser *user = [[CHUser alloc] init];
                    DLog(@"Invites: %@", responseObject[@"profile"][@"invites"]);
                    [user setUsername:responseObject[@"profile"][@"username"]];
                    [user setGroups:responseObject[@"profile"][@"groups"]];
                    [user setInvites:responseObject[@"profile"][@"invites"]];
                    self.currentUser = user;
                    
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DLog(@"Error: %@", error);

            }];

            
            callback(YES,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(NO, error);
    }];
}

- (void)registerWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
{
    DLog(@"username: %@, password: %@", username, password);
    [self POST:@"/user" parameters:@{@"username" : username, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            //self.sessiontoken = responseObject[@"session-token"];
            //[self.requestSerializer setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
            
            // Save the session token to avoid future login
            //[[NSUserDefaults standardUserDefaults]
             //setObject:self.sessiontoken forKey:@"session-token"];
            
            
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        //callback(error);
    }];
}

- (void)getGroups: (void (^)(NSArray *groups))callback {
    DLog(@"Using session token %@", self.sessiontoken);
    [self GET:[NSString stringWithFormat:@"/group"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
    }];
}

- (void)createGroupWithName: (NSString *)groupName callback: (void (^)(bool successful, NSError *error))callback;
{
    [self POST:@"/group" parameters:@{@"name" : groupName} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if( callback ) {
            callback(YES,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(NO, error);
    }];
}

- (void)getMessagesFromDate: (NSDate *)date group:(NSString *)group callback:(void (^)(NSArray *messages))callback;
{
    [self GET:[NSString stringWithFormat:@"/group/%@/messages?20140101", group/*, date*/] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            DLog(@"Received response from messages: %@", responseObject[@"messages"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error retrieving messages: %@", error);
    }];
}

- (void)getProfile: (void (^)(CHUser *userProfile))callback;
{
    [self GET:@"/user" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            CHUser *user = [[CHUser alloc] init];
            DLog(@"Invites: %@", responseObject[@"profile"][@"invites"]);
            [user setUsername:responseObject[@"profile"][@"username"]];
            [user setGroups:responseObject[@"profile"][@"groups"]];
            [user setInvites:responseObject[@"profile"][@"invites"]];
            self.currentUser = user;
            callback(user);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(nil);
    }];

}

- (void)getProfileOfUser: (NSString *)username callback: (void (^)(CHUser *userProfile))callback;
{
    //Return the users profile
}

- (void)sendInviteToUsers: (NSArray *)invitees groupId: (NSString *) groupId callback: (void (^)(bool successful, NSError *error))callback;
{
    /*[self POST:@"/group" parameters:@{@"name" : groupName} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if( callback ) {
            callback(YES,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(NO, error);
    }];*/
    
    // Add id
    NSString *url =[[NSString alloc] initWithFormat:@"/group/%@/invite",groupId];
   
    [self PUT:url parameters:@{@"invitees" : invitees} success:^(NSURLSessionDataTask *task, NSError *error) {
        
        callback(YES, nil);
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error sending invite %@", error);
        callback(NO, error);
    }];

}

- (void)acceptInviteAtIndex: (NSNumber *)index callback: (void (^)(bool successful, NSError *error))callback;
{
    [self POST:@"/user/accept" parameters:@{@"invite" : index} success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Accepted!");
        callback(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Invite not accepted");
        callback(NO, error);
    }];
}

- (void)sendMessageWithMessage: (NSString *)message callback: (void (^)(bool successful, NSError *error))callback;
{
#warning @"Not yet implemented!!"
//    [self ]
}


- (BOOL)hasStoredSessionToken;
{
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"session-token"];
    
    if( savedValue != nil ) {
        DLog(@"Setting session token to %@", savedValue);
        self.sessiontoken = savedValue;
        [self.requestSerializer setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
    }
    
    return savedValue != nil;
}



@end
