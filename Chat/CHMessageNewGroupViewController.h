//
//  CHMessageNewGroupViewController.h
//  Chat
//
//  Created by Ethan Mick on 9/30/14.
//
//

#import "CHMessageViewController.h"
#import "MBContactPicker.h"

@interface CHMessageNewGroupViewController : CHMessageViewController <MBContactPickerDataSource, MBContactPickerDelegate>

@property (nonatomic, strong) UIViewController *parent;
@property (strong, nonatomic) IBOutlet MBContactPicker *contactPickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pickerHeight;

- (IBAction)cancelTapped:(id)sender;

@end
