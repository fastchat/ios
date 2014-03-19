//
//  CHMessageViewController.h
//  Chat
//
//  Created by Michael Caputo on 3/18/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIScrollView *chatScrollView;
@property (weak, nonatomic) IBOutlet UITextView *messageDisplayTextView;

- (IBAction)sendButtonTouched:(id)sender;
@end
