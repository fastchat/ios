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
#import "CHModel.h"

NSString *const kAvatarKey = @"com.fastchat.avatarkey";
NSString *const kMediaKey = @"com.fastchat.mediakey";
NSString *const SESSION_TOKEN = @"session-token";
//#define BASE_URL @"http://10.0.0.10:3000"
#define BASE_URL @"http://powerful-cliffs-9562.herokuapp.com:80"

@interface CHNetworkManager()

@end

@implementation CHNetworkManager

#pragma mark - LifeCycle

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

- (void)setSessionToken:(NSString *)token;
{
    DLog(@"Setting Token: %@", token);
    [self.requestSerializer setValue:token forHTTPHeaderField:SESSION_TOKEN];
}

#pragma mark - Promises

- (PMKPromise *)loginWithUser:(CHUser *)user;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self POST:@"/login" parameters:@{@"username": user.username, @"password" : user.password}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               
               DLog(@"Response Object Login: %@", responseObject);
               NSString *token = responseObject[SESSION_TOKEN];
               user.sessionToken = token;
               [self setSessionToken:token];
               fulfiller(user);
               
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               DLog(@"Error: %@", error);
               rejecter(error);
           }];
    }];
}

- (PMKPromise *)currentUserProfile;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self GET:@"/user" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Profile: %@", responseObject);
            CHUser *user = [CHUser currentUser];
            user.username = responseObject[@"profile"][@"username"];
            user.chID = responseObject[@"profile"][@"_id"];
            NSArray *groups = [CHGroup objectsFromJSON:responseObject[@"profile"][@"groups"]];
            user.groups = [NSOrderedSet orderedSetWithSet:[NSSet setWithArray:groups]];
            [self save];
            fulfiller(user);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)logout;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self DELETE:@"/logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            fulfiller(nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)currentUserGroups;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self GET:@"/group" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            CHUser *user = [CHUser currentUser];
            NSArray *groups = [CHGroup objectsFromJSON:responseObject];
            user.groups = [NSOrderedSet orderedSetWithSet:[NSSet setWithArray:groups]];
            [self save];
            fulfiller(user);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)leaveGroup:(NSString *)groupId;
{
    NSString *url = [NSString stringWithFormat:@"%@/group/%@/leave", BASE_URL, groupId];
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self PUT:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            fulfiller(nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)avatarForUser:(CHUser *)user;
{
    DLog(@"Avatar FOR: %@", user);
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        ///
        /// First check our secret cache
        ///
        NSString *key = [NSString stringWithFormat:@"%@-%@", kAvatarKey, user.chID];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:key];
        UIImage *avatar = [UIImage imageWithData:data];
        if (avatar) {
            fulfiller(avatar);
        }
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:
                                        [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/%@/avatar", BASE_URL, user.chID]]];
        [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
        
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [defaults setObject:UIImagePNGRepresentation(responseObject) forKey:key];
                    [defaults synchronize];
                });
            }
            fulfiller(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
        
        [requestOperation start];
    }];
}

- (PMKPromise *)newGroupWithName:(id)name members:(NSArray *)members;
{
    if (!name) {
        name = [NSNull null];
    }
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self POST:@"/group"
        parameters:@{@"name" : name, @"members" : members, @"text" : @"Group created"}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               CHGroup *newGroup = [CHGroup objectFromJSON:responseObject];
               [self save];
               fulfiller(newGroup);
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               DLog(@"Error: %@", error);
               rejecter(error);
           }];
    }];
}

- (void)createGroupWithName: (NSString *)groupName members: (NSArray *)members callback: (void (^)(bool successful, NSError *error))callback;
{
    [self POST:@"/group" parameters:@{@"name" : groupName, @"members" : members, @"text" : @"Group created"} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            callback(YES,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(NO, error);
    }];
}

#pragma mark - Old

- (void)registerWithUsername: (NSString *)username password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
{
    [self POST:@"/user" parameters:@{@"username" : username, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
    }];
}

- (void)getMessagesFromDate: (NSDate *)date group:(NSString *)group callback:(void (^)(NSArray *messages))callback;
{
    [self GET:[NSString stringWithFormat:@"/group/%@/message?20140101", group/*, date*/] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error retrieving messages: %@", error);
    }];
}

- (void)getMediaForMessage:(NSString *)messageId groupId:(NSString *)groupId callback:(void (^)(UIImage *messageMedia))callback;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@-%@-%@", kMediaKey, groupId, messageId];
    NSData *data = [defaults objectForKey:key];
    UIImage *image = [UIImage imageWithData:data];
    if (image) {
        if (callback) {
            callback(image);
            return;
        }
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:
                                    [NSURL URLWithString:
                                     [NSString stringWithFormat:@"%@/group/%@/message/%@/media", BASE_URL, groupId, messageId]]];
    [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = UIImagePNGRepresentation(responseObject);
                [defaults setObject:data forKey:key];
                [defaults synchronize];
            });
        }
        if(callback) {
            callback(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
        if (callback) {
            callback(nil);
        }
    }];
    
    [requestOperation start];
}

- (void)getMessagesForGroup:(NSString *)group page:(NSInteger)page callback:(void (^)(NSArray *messages))callback;
{
    if( !page ) {
        [self GET:[NSString stringWithFormat:@"/group/%@/message", group] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
        [self GET:[NSString stringWithFormat:@"/group/%@/message?page=%ld", group, (long)page] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
    
    [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          callback(YES, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          NSLog(@"Error: %@", error);
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
        callback(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        callback(NO, error);
    }];
}

- (void)postDeviceToken:(NSData *)token callback:(void (^)(BOOL success, NSError *error))callback;
{
    NSString *tokenString = [NSString stringWithFormat:@"%@", token];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<|\\s|>)" options:NSRegularExpressionCaseInsensitive error:nil];
    tokenString = [regex stringByReplacingMatchesInString:tokenString options:0 range:NSMakeRange(0, [tokenString length]) withTemplate:@""];
    
    [self POST:@"/user/device" parameters:@{@"token": tokenString, @"type" : @"ios"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (callback) {
            callback(YES, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (callback) {
            callback(NO, error);
        }
    }];
}


- (void)postMediaMessageWithImage:(UIImage *)image
                          groupId:(NSString *)groupId
                          message:(NSString *)message
                         callback:(void (^)(BOOL success, NSError *error))callback;
{

    NSData *imageData = UIImagePNGRepresentation(image);
    NSDictionary *parameters = nil;
    
    NSString *url = [NSString stringWithFormat:@"%@/group/%@/message", BASE_URL, groupId];
    NSError *error = nil;
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString]
                                                                               parameters:parameters
                                                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                    NSString *randomName = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                                                                    [formData appendPartWithFileData:imageData
                                                                                                name:@"media"
                                                                                            fileName:randomName
                                                                                            mimeType:@"image/png"];
                                                                    
                                                                    [formData appendPartWithFormData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                name:@"text"];
                                                                } error:&error];
    
    [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          DLog(@"Successfully posted the image!");
                                                                          callback(YES, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          NSLog(@"Error: %@", error);
                                                                          callback(NO, error);
                                                                      }];
    [self.operationQueue addOperation:operation];
    
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

- (void)save;
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
                                         
                                         


@end
