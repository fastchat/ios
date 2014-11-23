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
#import "CHBackgroundContext.h"
#import "CHMessageViewController.h"
#import "CHGroup.h"
#import "UIResponder+KeyboardCache.h"

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    ///
    /// Magical Record starting point
    ///
    [MagicalRecord setupAutoMigratingCoreDataStack];
    
    ///
    /// Race Conditions, go!
    ///
    [CHBackgroundContext backgroundContext].start.then(^{
        
    });
    
    ///
    /// Fucking Cache the keyboard
    ///
    [UIResponder cacheKeyboard];
    
    ///
    /// Setup the networking layer and get ready to connect
    ///
    [[CHSocketManager sharedManager] openSocket];
    
    ///
    /// Setup Google Analytics
    ///
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-54229110-2"];
    
    ///
    /// Clear out the annoying notifications
    ///
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    ///
    /// Set a nice uncaught exception handler for debugging
    ///
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    ///
    /// UI Appearance, makes it all pretty.
    ///
    [[UINavigationBar appearance] setBarTintColor:kPurpleAppColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:kPurpleAppColor];
    [[UIButton appearance] setTintColor:kPurpleAppColor];
    
    
    NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [self application:application didReceiveRemoteNotification:notification fetchCompletionHandler:nil];
    }
    
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
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
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
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [MagicalRecord cleanUp];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[CHNetworkManager sharedManager] postDeviceToken:deviceToken].then(^{
        
    }).catch(^(NSError *error){
        
    });
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
{
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
}

/**
 * Called when we get a push notification, and also when the app opens.
 */
- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(NSDictionary *)userInfo
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
{
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        NSString *groupID = userInfo[@"group"];
        if (groupID && [CHUser currentUser]) {
            
            UITabBarController *root = (UITabBarController *)self.window.rootViewController;
            [root setSelectedIndex:0];
            UINavigationController *nav = root.viewControllers[0];
            
            UIViewController *top = nav.viewControllers.lastObject;
            if ([top isKindOfClass:[CHMessageViewController class]]) {
                CHMessageViewController *messageVC = (CHMessageViewController *)top;
                if ([messageVC.group.chID isEqualToString:groupID]) {
                    return;
                }
            }
            
            [nav popToRootViewControllerAnimated:NO];
            
            CHGroup *group = [CHGroup MR_findFirstByAttribute:@"chID" withValue:groupID];
            if (group) {
                CHMessageViewController *vc = [[CHMessageViewController alloc] initWithGroup:group];
                [group setUnreadValue:0];
                [nav pushViewController:vc animated:YES];
            }
        }
    }
    
    
    if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

@end
