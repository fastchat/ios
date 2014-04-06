//
//  CHAddGroupViewController.m
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import "CHAddGroupViewController.h"
#import "CHNetworkManager.h"
#include "CHAppDelegate.h"
#include "CHSideNavigationTableViewController.h"

@interface CHAddGroupViewController ()

@end

@implementation CHAddGroupViewController

UITapGestureRecognizer* tapGesture;
UIPanGestureRecognizer* panGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(createGroup)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createGroup {
    NSMutableArray *members = [[NSMutableArray alloc] init];
    if (![self.firstMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.firstMemberTextField.text];
    }
    if (![self.secondMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.secondMemberTextField.text];
    }
    if (![self.thirdMemberTextField.text isEqualToString:@""]) {
        [members addObject:self.thirdMemberTextField.text];
    }
    
    if( members.count >= 1 ) {
        DLog(@"Adding");
        if( ![self.groupNameTextField.text isEqualToString:@""] && self.groupNameTextField.text != nil) {
            DLog(@"Test");
            [[CHNetworkManager sharedManager] createGroupWithName:self.groupNameTextField.text members:members callback:^(bool successful, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadGroupListTable" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



// Side nav
-(IBAction)showLogoExpandingViewController
{
    // this sets the currentViewController on the app_delegate to the expanding view controller
    // then slides the screenshot back over
    
    
    [(CHAppDelegate *)[[UIApplication sharedApplication] delegate] setContentViewControllerWithController:[[CHSideNavigationTableViewController alloc] initWithNibName:@"CHSideNavigationTableViewController" bundle:nil]];
    [self slideThenHide];
}

-(void) slideThenHide
{
    // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
    // it tells the app delegate using the completion block of the animation
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.screenShotImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
                     completion:^(BOOL finished){ [(CHAppDelegate *)[[UIApplication sharedApplication] delegate] hideSideMenu]; }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // remove the gesture recognizers
    [self.screenShotImageView removeGestureRecognizer:tapGesture];
    [self.screenShotImageView removeGestureRecognizer:panGesture];
}

- (void)singleTapScreenShot:(UITapGestureRecognizer *)gestureRecognizer
{
    // on a single tap of the screenshot, assume the user is done viewing the menu
    // and call the slideThenHide function
    [self slideThenHide];
}

/* The following is from http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ */
-(void)panGestureMoveAround:(UIPanGestureRecognizer *)gesture;
{
    UIView *piece = [gesture view];
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        
        // I edited this line so that the image view cannont move vertically
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
        [gesture setTranslation:CGPointZero inView:[piece superview]];
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded)
        [self slideThenHide];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


@end
