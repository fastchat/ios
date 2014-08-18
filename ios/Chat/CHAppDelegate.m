//
//  CHAppDelegate.m
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import "CHAppDelegate.h"
#import "CHNetworkManager.h"
#import "CHSocketManager.h"
#import "CHUser.h"
#import "TSMessage.h"

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    ///
    /// Magical Record starting point
    ///
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    ///
    ///
    ///
    [[CHNetworkManager sharedManager] hasStoredSessionToken];
    
    ///
    ///
    ///
    [[CHSocketManager sharedManager] openSocket];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    ///
    /// UI Appearance, makes it all pretty.
    ///
    [[UINavigationBar appearance] setBarTintColor:kPurpleAppColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:kPurpleAppColor];
    [[UIButton appearance] setTintColor:kPurpleAppColor];
    
    return YES;
}

/**
 * This gives us a stack trace when the app crashes. Very useful for catching issues, especially
 * when Xcode stops giving us stack traces. No idea why.
 */
void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

							
- (void)applicationWillResignActive:(UIApplication *)application;
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
    [[CHSocketManager sharedManager] closeSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application;
{
    [[CHSocketManager sharedManager] openSocket];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadActiveGroupNotification object:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    [[CHSocketManager sharedManager] openSocket];
//    if ( [CHUser currentUser] != nil ) {
////        if ( [[CHNetworkManager sharedManager] currentUser] == nil ) {
//            [[CHNetworkManager sharedManager] getProfile:^(CHUser *userProfile) {
//                CHUser *user = [[CHNetworkManager sharedManager] currentUser];
//                
//                [[CHNetworkManager sharedManager] getAvatarOfUser:user.chID callback:^(UIImage *avatar) {
//                    user.avatar = avatar;
//                    [[CHNetworkManager sharedManager] setCurrentUser:user];
//                }];
//            }];
////        }
//    }
    
    ///
    /// Load any new messages if the app was inactive or phone was locked
    ///
    
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
    [MagicalRecord cleanUp];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[CHNetworkManager sharedManager] postDeviceToken:deviceToken callback:^(BOOL success, NSError *error) {
        DLog(@"Error Posting Token: %@", error);
    }];
}

/**
 * Called when we get a push notification, and also when the app opens.
 */
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
{
    
    
    
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
