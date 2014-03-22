//
//  CHNetworkManager.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHNetworkManager.h"

#define BASE_URL @"http://localhost:3000"

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

-(void)postLoginWithEmail: (NSString *)email password:(NSString *)password callback:(void (^)(bool successful, NSError *error))callback;
{
    [self POST:@"/login" parameters:@{@"email" : email, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            self.sessiontoken = responseObject[@"session-token"];
            [self.requestSerializer setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
            
            // Save the session token to avoid future login
            [[NSUserDefaults standardUserDefaults]
             setObject:self.sessiontoken forKey:@"session-token"];

            
            callback(YES,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error: %@", error);
        callback(NO, error);
    }];
}

- (void)registerWithEmail: (NSString *)email password:(NSString *)password callback:(void (^)(NSArray *userData))callback;
{
    DLog(@"email: %@, password: %@", email, password);
    [self POST:@"/register" parameters:@{@"email" : email, @"password" : password} success:^(NSURLSessionDataTask *task, id responseObject) {
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
    [self GET:[NSString stringWithFormat:@"/group/5328d87af8d3d3af7b000003/messages?20140101"/*, group, date*/] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if( callback ) {
            DLog(@"Received response from messages: %@", responseObject[@"messages"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error retrieving messages: %@", error);
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
        self.sessiontoken = savedValue;
        [self.requestSerializer setValue:self.sessiontoken forHTTPHeaderField:@"session-token"];
    }
    
    return savedValue != nil;
}



@end
