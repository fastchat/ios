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

- (PMKPromise *)registerWithUser:(CHUser *)user;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self POST:@"/user" parameters:@{@"username" : user.username, @"password" : user.password}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               NSLog(@"Register Response: %@", responseObject);
               fulfiller(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
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
               DLog(@"New Group Response: %@", responseObject);
               CHGroup *newGroup = [CHGroup objectFromJSON:responseObject];
               [self save];
               DLog(@"Group: %@", newGroup);
               fulfiller(newGroup);
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               DLog(@"Error: %@", error);
               rejecter(error);
           }];
    }];
}

- (PMKPromise *)messagesForGroup:(CHGroup *)group page:(NSInteger)page;
{
    NSString *url = [NSString stringWithFormat:@"/group/%@/message?page=%ld", group.chID, (long)page];
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *messages = [CHMessage objectsFromJSON:responseObject];
            NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:messages];
            [group addMessages:set];
            [self save];
            fulfiller(messages);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error retrieving messages: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)postMediaMessageWithImage:(UIImage *)image
                                  groupId:(NSString *)groupId
                                  message:(NSString *)message;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *url = [NSString stringWithFormat:@"%@/group/%@/message", BASE_URL, groupId];
        NSError *error = nil;
        
        NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                    URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString]
                                                                                   parameters:nil
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
                                                                              fulfiller(responseObject);
                                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              NSLog(@"Error: %@", error);
                                                                              rejecter(error);
                                                                          }];
        [self.operationQueue addOperation:operation];
        
    }];
}

- (PMKPromise *)mediaForMessage:(CHMessage *)message;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@/group/%@/message/%@/media", BASE_URL, message.group.chID, message.chID];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            fulfiller(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
            rejecter(error);
        }];
        
        [requestOperation start];
    }];
}

- (PMKPromise *)newUsers:(NSArray *)invitees forGroup:(CHGroup *)group;
{
    if (!invitees) {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
            fulfiller(nil);
        }];
    }
    NSString *url =[NSString stringWithFormat:@"/group/%@/add", group.chID];
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self PUT:url
       parameters:@{@"invitees": invitees}
          success:^(NSURLSessionDataTask *task, id responseObject) {
              fulfiller(responseObject);
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              rejecter(error);
          }];
    }];
}

- (PMKPromise *)postDeviceToken:(NSData *)token;
{
    NSString *tokenString = [NSString stringWithFormat:@"%@", token];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<|\\s|>)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    tokenString = [regex stringByReplacingMatchesInString:tokenString
                                                  options:0
                                                    range:NSMakeRange(0, [tokenString length])
                                             withTemplate:@""];
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self POST:@"/user/device"
        parameters:@{@"token": tokenString, @"type" : @"ios"}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               fulfiller(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            rejecter(error);
        }];
    }];
    
}


- (PMKPromise *)newAvatar:(UIImage *)image forUser:(CHUser *)user;
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSDictionary *parameters = nil;
    
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/avatar", BASE_URL, user.chID];
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
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                              fulfiller(responseObject);
                                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              rejecter(error);
                                                                          }];
        [self.operationQueue addOperation:operation];
    }];
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
