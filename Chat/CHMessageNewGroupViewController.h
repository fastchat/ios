//
//  CHMessageNewGroupViewController.h
//  Chat
//
//  Created by Ethan Mick on 9/30/14.
//
//

#import "CHMessageViewController.h"
#import "THContactPickerView.h"

@interface CHMessageNewGroupViewController : CHMessageViewController <THContactPickerDelegate>

@property (nonatomic, strong) THContactPickerView *picker;

- (IBAction)saveGroup:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
