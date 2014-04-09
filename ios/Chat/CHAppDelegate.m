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

@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[CHNetworkManager sharedManager] hasStoredSessionToken];
    [[CHSocketManager sharedManager] openSocket];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    return YES;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DLog(@"");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DLog(@"");
    [[CHSocketManager sharedManager] closeSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Reload message table
    DLog(@"");
    [[CHSocketManager sharedManager] openSocket];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DLog(@"");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAppDelegateTable" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    [[CHNetworkManager sharedManager] postDeviceToken:deviceToken callback:^(BOOL success, NSError *error) {
        DLog(@"Success? %@", success ? @"YES" : @"NO");
        DLog(@"ERror: %@", error);
    }];
    
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - Side Menu

-(void)showSideMenu;
{
    DLog(@"Showing side menu");
    // before swaping the views, we'll take a "screenshot" of the current view
    // by rendering its CALayer into the an ImageContext then saving that off to a UIImage
    CGSize viewSize = self.contentViewController.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [self.contentViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Read the UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // pass this image off to the MenuViewController then swap it in as the rootViewController
    self.menuViewController.screenShotImage = image;
    self.window.rootViewController = self.menuViewController;
}

-(void)hideSideMenu;
{
    // all animation takes place elsewhere. When this gets called just swap the contentViewController in
    self.window.rootViewController = self.contentViewController;
}

-(void)setContentViewControllerWithController: (CHSideNavigationTableViewController*)controller;
{
    self.contentViewController = controller;
}

@end
