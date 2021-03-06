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
#import "AFNetworkActivityIndicatorManager.h"
#import "CHBackgroundContext.h"
#import "CHConstants.h"

NSString *const kAvatarKey = @"com.fastchat.avatarkey";
NSString *const kMediaKey = @"com.fastchat.mediakey";
NSString *const SESSION_TOKEN = @"session-token";

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
    if( (self = [super initWithBaseURL:[NSURL URLWithString:BASE_PATH]]) ) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        self.completionQueue = [CHBackgroundContext backgroundContext].queue;
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
               fulfiller(nil);
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
               DLog(@"Register Response: %@", responseObject);
               fulfiller(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Erorr: %@ %@", error, task.response);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)currentUserProfile;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self GET:@"/user" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"Profile: %@", responseObject);
            // This must be on the main thread
            id q = dispatch_get_main_queue();
            dispatch_async(q, ^{
                NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
                CHUser *user = [CHUser currentUser];
                user.chID = responseObject[@"profile"][@"_id"];
                
                id backgroundQ = [CHBackgroundContext backgroundContext].queue;
                [CHGroup objectsFromJSON:responseObject[@"profile"][@"groups"]].thenOn(backgroundQ, ^(NSArray *groups) {
                    DLog(@"Made %@", groups);
                    NSManagedObjectContext *bContext = [CHBackgroundContext backgroundContext].context;
                    [bContext reset];
                    return [CHGroup MR_findAllInContext:bContext];
                }).then(^(NSArray *groups) {
                    DLog(@"Start %@", groups);
                    NSMutableArray *actualGroups = [NSMutableArray array];
                    for (CHGroup *g in groups) {
                        CHGroup *transfered = [CHGroup objectID:g.actualObjectId toContext:context];
                        if (transfered) {
                            [actualGroups addObject:transfered];
                        }
                    }
                    
                    DLog(@"Groups %@", actualGroups);
                    user.groups = [NSOrderedSet orderedSetWithSet:[NSSet setWithArray:actualGroups]];
//                }).thenOn(backgroundQ, ^{
//                    return [CHGroup objectsFromJSON:responseObject[@"profile"][@"leftGroups"]];
//                }).then(^(NSArray *past) {
//                    NSMutableArray *actualGroups = [NSMutableArray array];
//                    for (CHGroup *g in past) {
//                        CHGroup *transfered = [CHGroup objectID:g.actualObjectId toContext:context];
//                        if (transfered) {
//                            [actualGroups addObject:transfered.actualObjectId];
//                        }
//                    }
//                    user.pastGroups = [NSOrderedSet orderedSetWithSet:[NSSet setWithArray:actualGroups]];
                }).then(^{
                    [self saveWithContext:context];
                    DLog(@"USERNAME: %@", user.username);
                    fulfiller(user);
                });
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)updateUserSettings:(NSDictionary *)settings;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        fulfill(nil);
    }];
}

- (PMKPromise *)logout:(BOOL)all;
{
    NSString *url = @"/logout";
    if (all) {
        url = [url stringByAppendingString:@"?all=true"];
    }
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
            DLog(@"Groups: %@", responseObject);
            
            NSManagedObjectContext *context = [CHBackgroundContext backgroundContext].context;
            id q = [CHBackgroundContext backgroundContext].queue;
            
            CHUser *user = [CHUser object:[CHUser currentUser] toContext:context];
            [context performBlock:^{
                [CHGroup objectsFromJSON:responseObject].thenOn(q, ^(NSArray *groups){
                    user.groups = [NSOrderedSet orderedSetWithSet:[NSSet setWithArray:groups]];
                    [self saveWithContext:context];
                    fulfiller(user);
                });
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
    }];
}

- (PMKPromise *)leaveGroup:(NSString *)groupId;
{
    NSString *url = [NSString stringWithFormat:@"/group/%@/leave", groupId];
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
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:
                                        [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/%@/avatar", BASE_PATH, user.chID]]];
        [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
        
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                fulfiller(responseObject);
            } else {
                rejecter([NSError errorWithDomain:@"FastChat" code:1 userInfo:@{NSLocalizedDescriptionKey: @"No Avatar Found!"}]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error: %@", error);
            rejecter(error);
        }];
        
        [requestOperation start];
    }];
}

- (PMKPromise *)newGroupWithName:(NSString *)name members:(NSArray *)members message:(NSString *)message;
{
    id finalName = name;
    if (!finalName) {
        finalName = [NSNull null];
    }
    
    id finalMessage = message;
    if (!finalMessage) {
        finalMessage = [NSNull null];
    }
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self POST:@"/group"
        parameters:@{@"name" : finalName, @"members" : members, @"text" : finalMessage}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   CHGroup *newGroup = [CHGroup objectFromJSON:responseObject];
                   
                   
                   [self saveWithContext:[NSManagedObjectContext MR_defaultContext]];
                   fulfiller(newGroup);
               });
               
               
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               DLog(@"Error: %@", error);
               rejecter(error);
           }];
    }];
}

- (PMKPromise *)messagesForGroup:(CHGroup *)foreignGroup page:(NSInteger)page;
{
    NSString *url = [NSString stringWithFormat:@"/group/%@/message?page=%ld", foreignGroup.chID, (long)page];
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSManagedObjectContext *context = [CHBackgroundContext backgroundContext].context;
            
            CHGroup *group = [CHGroup object:foreignGroup toContext:context];
            
            id q = [CHBackgroundContext backgroundContext].queue;
            [context performBlock:^{
                [CHMessage objectsFromJSON:responseObject].thenOn(q, ^(NSArray *messages) {
                    NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:messages];
                    [group addMessages:set];
                    [self saveWithContext:context];
                    fulfiller(messages);
                });
            }];
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
        NSString *url = [NSString stringWithFormat:@"%@/group/%@/message", BASE_PATH, groupId];
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
                                                                              DLog(@"Error: %@", error);
                                                                              rejecter(error);
                                                                          }];
        [self.operationQueue addOperation:operation];
        
    }];
}

- (PMKPromise *)mediaForMessage:(CHMessage *)message;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@/group/%@/message/%@/media", BASE_PATH, message.group.chID, message.chID];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setValue:[CHUser currentUser].sessionToken forHTTPHeaderField:@"session-token"];
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            fulfiller(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Image error: %@", error);
            rejecter(error);
        }];
        
        [requestOperation start];
    }];
}

- (PMKPromise *)newUsers:(NSArray *)invitees forGroup:(CHGroup *)group;
{
    if (!invitees || invitees.count == 0) {
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
    
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/avatar", BASE_PATH, user.chID];
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

- (PMKPromise *)imageFromURL:(NSURL *)url;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            
            fulfill(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"IMAGEERROR: %@", error);
            reject(error);
        }];
        [operation start];
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

- (void)saveWithContext:(NSManagedObjectContext *)context;
{
    [context MR_saveToPersistentStoreAndWait];
}



@end
