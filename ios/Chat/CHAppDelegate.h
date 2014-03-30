//
//  CHAppDelegate.h
//  Chat
//
//  Created by Ethan Mick on 3/15/14.
//
//

#import <UIKit/UIKit.h>
#import "CHMenuViewController.h"
#import "CHSideNavigationTableViewController.h"

@interface CHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *contentViewController;
@property (strong, nonatomic) CHMenuViewController *menuViewController;

-(void)setContentViewControllerWithController: (CHSideNavigationTableViewController*)controller;
-(void)showSideMenu;
-(void)hideSideMenu;

@end
