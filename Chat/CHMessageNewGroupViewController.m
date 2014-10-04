//
//  CHMessageNewGroupViewController.m
//  Chat
//
//  Created by Ethan Mick on 9/30/14.
//
//

#import "CHMessageNewGroupViewController.h"

@interface CHMessageNewGroupViewController ()

@end

@implementation CHMessageNewGroupViewController

- (instancetype)init
{
    self = [super initWithGroup:nil];
    if (self) {
        self.title = @"New Group";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                               target:self
                                                                                               action:@selector(cancelTapped:)];
        
        [self presentKeyboard:NO];
    }
    return self;
}

- (void)loadView;
{
    [super loadView];
    [self.view addSubview:self.picker];
    
    [self.picker addContact:@"" withName:@"John"];
}

- (THContactPickerView *)picker;
{
    if (!_picker) {
        _picker = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 100)];
        _picker.delegate = self;
    }
    return _picker;
}

- (void)loadNextMessages;
{
    if (self.group != nil) {
        [self actuallyLoad];
    }
}

- (void)actuallyLoad;
{
    [self messagesAtPage:self.page]
    .then(self.loadInNewMessages)
    .catch(^(NSError *error) {
        DLog(@"Error: %@", error);
    }).finally(^{
        self.page++;
        [self refreshOn:NO];
    });
}

- (IBAction)saveGroup:(id)sender;
{
//    NSMutableArray *members = [[NSMutableArray alloc] init];
//    if (![self.firstMemberTextField.text isEqualToString:@""]) {
//        [members addObject:self.firstMemberTextField.text];
//    }
//    if (![self.secondMemberTextField.text isEqualToString:@""]) {
//        [members addObject:self.secondMemberTextField.text];
//    }
//    if (![self.thirdMemberTextField.text isEqualToString:@""]) {
//        [members addObject:self.thirdMemberTextField.text];
//    }
//    
//    if( members.count >= 1 ) {
//        [CHGroup groupWithName:self.groupNameTextField.text members:members].then(^(CHGroup *group){
//            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGroupTablesNotification object:nil];
//            [self dismissViewControllerAnimated:YES completion:nil];
//        });
//    }
}

- (IBAction)cancelTapped:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Delegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
{
    DLog(@"TExt: %@", textViewText);
}

- (void)contactPickerDidRemoveContact:(id)contact;
{
    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView;
{
    
}

@end
