//
//  CHNetworkManager.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHNetworkManager.h"
#import "CHUser.h"
#import "CHGroup.h"
#import "CHMessage.h"
#import "AFNetworking.h"
#import "CHGroupsCollectionAccessor.h"

//#define BASE_URL @"http://10.0.0.10:3000"
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

-(void)logoutWithCallback: (void (^)(bool successful, NSError *error))callback;
{
    [self DELETE:@"/logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Logged out successfully");
        self.sessiontoken = nil;
        self.currentUser = nil;
        callback(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error logging out: %@", error);
        callback(NO, error);
    }];
}

- (void)registerWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
{
    DLog(@"username: %@, password: %@", username, password);
    [self POST:@"/user" parameters:@{@"username" : username, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
    }];
}

- (void)getGroups: (void (^)(NSArray *groups))callback {
    DLog(@"Using session token %@", self.sessiontoken);
    [self GET:[NSString stringWithFormat:@"/group"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            NSArray *groups = [CHGroup objectsFromJSON:responseObject];

            [[CHGroupsCollectionAccessor sharedAccessor] addGroupsWithArray:groups];
            
            callback(groups);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
    }];
}

- (void)createGroupWithName: (NSString *)groupName members: (NSArray *)members callback: (void (^)(bool successful, NSError *error))callback;
{
    DLog(@"HERE");
    [self POST:@"/group" parameters:@{@"name" : groupName, @"members" : members, @"text" : @"Group created"} success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Making call");
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

- (void)getMessagesForGroup:(NSString *)group page:(int)page callback:(void (^)(NSArray *messages))callback;
{
    DLog(@"The group id is %@", group);
    if( !page ) {
        [self GET:[NSString stringWithFormat:@"/group/%@/messages", group] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if( callback ) {
                NSArray *messages = [CHMessage objectsFromJSON:responseObject];
            
                callback(messages);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error retrieving messages: %@", error);
            if (callback) {
                callback(nil);
            }
        }];
    }
    else {
        DLog(@"Using page: %d", page);
        [self GET:[NSString stringWithFormat:@"/group/%@/messages?page=%d", group, page] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if( callback ) {
                NSArray *messages = [CHMessage objectsFromJSON:responseObject];
                
                callback(messages);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error retrieving messages: %@", error);
            if (callback) {
                callback(nil);
            }
        }];
    }
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
            user.userId = responseObject[@"profile"][@"_id"];
            
            self.currentUser = user;
            callback(user);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(nil);
    }];

}

- (void)getAvatarOfUser: (NSString *)userId callback: (void (^)(UIImage *avatar))callback;
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user/%@/avatar",BASE_URL, userId]]];
    [request setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);

        if (self.currentUser) {
            self.currentUser.avatar = responseObject;
        }
        if(callback) {
            callback(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    
    [requestOperation start];
}

- (void)pushNewAvatarForUser: (NSString *)userId avatarImage: (UIImage *)avatarImage callback: (void (^)(bool successful, NSError *error))callback;
{
    NSData *imageData = UIImagePNGRepresentation(avatarImage);
    NSDictionary *parameters = nil;
    
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/avatar", BASE_URL, userId];
    NSError *error = nil;
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString]
                                                                               parameters:parameters
                                                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                    [formData appendPartWithFileData:imageData
                                                                                                name:@"avatar"
                                                                                            fileName:@"myavatar.png"
                                                                                            mimeType:@"image/png"];
                                                                } error:&error];
    
    DLog(@"Error? %@", error);
    [request setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
//    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          NSLog(@"Success: %@", responseObject);
                                                                          callback(YES, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          NSLog(@"Error: %@", error);
                                                                          DLog(@"Response: %@", operation.responseString);
                                                                          callback(NO, error);
                                                                      }];
    [self.operationQueue addOperation:operation];
}

- (void)addNewUsers: (NSArray *)invitees groupId: (NSString *) groupId callback: (void (^)(bool successful, NSError *error))callback;
{
    // Add id
    NSString *url =[[NSString alloc] initWithFormat:@"/group/%@/add",groupId];
   
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

- (void)postDeviceToken:(NSData *)token callback:(void (^)(BOOL success, NSError *error))callback;
{
    NSString *tokenString = [NSString stringWithFormat:@"%@", token];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<|\\s|>)" options:NSRegularExpressionCaseInsensitive error:nil];
    tokenString = [regex stringByReplacingMatchesInString:tokenString options:0 range:NSMakeRange(0, [tokenString length]) withTemplate:@""];
    
    DLog(@"MADE TOKEN: %@", tokenString);
    
    [self POST:@"/user/device" parameters:@{@"token": tokenString, @"type" : @"ios"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DLog(@"Response: %@", responseObject);
        
        if (callback) {
            callback(YES, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (callback) {
            callback(NO, error);
        }
    }];
}

- (void)putLeaveGroup:(NSString *)groupId callback:(void (^)(BOOL success, NSError *error))callback;
{
    NSString *url = [NSString stringWithFormat:@"/group/%@/leave", groupId];
    [self PUT:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        callback(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        callback(NO, error);
    }];
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

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = NO;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}
                                         
                                         


@end
