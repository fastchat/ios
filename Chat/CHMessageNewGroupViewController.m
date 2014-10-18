//
//  CHMessageNewGroupViewController.m
//  Chat
//
//  Created by Ethan Mick on 9/30/14.
//
//

#import "CHMessageNewGroupViewController.h"
#import "MBContactModel.h"
#import "CHGroup.h"
#import "CHGroupListTableViewController.h"
#import "UIViewController+PromiseKit.h"

@interface CHMessageNewGroupViewController ()

@property (nonatomic, copy) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *addedContacts;

@end

@implementation CHMessageNewGroupViewController

- (instancetype)init
{
    self = [super initWithGroup:nil];
    if (self) {
        self.title = @"New Group";
        self.addedContacts = [NSMutableArray array];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                               target:self
                                                                                               action:@selector(cancelTapped:)];
        
        NSArray *array = @[
                           @{@"Name":@"mike"},
                           @{@"Name":@"dave"},
                           @{@"Name":@"jared"},
                           @{@"Name":@"brian"},
                           @{@"Name":@"."},
                           @{@"Name":@"test1"}
                           ];
        
        NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:array.count];
        for (NSDictionary *contact in array)
        {
            MBContactModel *model = [[MBContactModel alloc] init];
            model.contactTitle = contact[@"Name"];
            [contacts addObject:model];
        }
        self.contacts = contacts;
        
        [self presentKeyboard:NO];
    }
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self.contactPickerView becomeFirstResponder];
}

- (void)addViewConstraints;
{
    if (!_contactPickerView) {
        [self.view addSubview:self.contactPickerView];
        
        NSDictionary *views = @{@"contactPickerView": self.contactPickerView,
                                @"textInputbar": self.textInputbar};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[contactPickerView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contactPickerView]-[textInputbar]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    }
}

- (MBContactPicker *)contactPickerView;
{
    if (!_contactPickerView) {
        _contactPickerView = [[MBContactPicker alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 100)];
        _contactPickerView.delegate = self;
        _contactPickerView.datasource = self;
    }
    return _contactPickerView;
}

- (void)loadNextMessages;
{
    if (self.group) {
        [super loadNextMessages];
    }
}

- (void)textUpdated;
{
    if (self.group) {
        [super textUpdated];
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

- (void)didPressRightButton:(id)sender;
{
    if (self.group) {
        [super didPressRightButton:sender];
    } else {
        [CHGroup groupWithName:nil members:self.addedContacts message:self.textView.text].then(^(CHGroup *group) {
            self.group = group;
            self.title = self.group.name;
            [self.contactPickerView removeFromSuperview];
            [self.textView becomeFirstResponder];
            [self loadNextMessages];
            self.textView.text = @"";
            [self fulfill:self];
        }).catch(^(NSError *error) {
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
    }
}

- (void)updateRightButtonEnabledState;
{
    [self.rightButton setEnabled:self.addedContacts.count != 0];
}

- (IBAction)cancelTapped:(id)sender;
{
    [self reject:nil];
}

#pragma mark - Delegate

// Use this method to give the contact picker the entire set of possible contacts.  Required.
- (NSArray *)contactModelsForContactPicker:(MBContactPicker*)contactPickerView
{
    return self.contacts;
}

// Use this method to pre-populate contacts in the picker view.  Optional.
- (NSArray *)selectedContactModelsForContactPicker:(MBContactPicker*)contactPickerView
{
    return @[];
}

#pragma mark - MBContactPickerDelegate

// Optional
- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didSelectContact:(id<MBContactPickerModelProtocol>)model
{

}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didAddContact:(id<MBContactPickerModelProtocol>)model
{
    [self.addedContacts addObject:model.contactTitle];
    [self updateRightButtonEnabledState];
}

- (void)contactCollectionView:(MBContactCollectionView*)contactCollectionView didRemoveContact:(id<MBContactPickerModelProtocol>)model
{
    [self.addedContacts removeObject:model.contactTitle];
    [self updateRightButtonEnabledState];
}

// Optional
// This delegate method is called to allow the parent view to increase the size of
// the contact picker view to show the search table view
- (void)didShowFilteredContactsForContactPicker:(MBContactPicker*)contactPicker
{
    if (self.pickerHeight.constant <= contactPicker.currentContentHeight)
    {
        [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
            CGRect pickerRectInWindow = [self.view convertRect:contactPicker.frame fromView:nil];
            CGFloat newHeight = self.view.window.bounds.size.height - pickerRectInWindow.origin.y - contactPicker.keyboardHeight;
            self.pickerHeight.constant = newHeight;
            [self.view layoutIfNeeded];
        }];
    }
}

// Optional
// This delegate method is called to allow the parent view to decrease the size of
// the contact picker view to hide the search table view
//- (void)didHideFilteredContactsForContactPicker:(MBContactPicker*)contactPicker
//{
//    if (self.contactPickerViewHeightConstraint.constant > contactPicker.currentContentHeight)
//    {
//        [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
//            self.contactPickerViewHeightConstraint.constant = contactPicker.currentContentHeight;
//            [self.view layoutIfNeeded];
//        }];
//    }
//}

// Optional
// This delegate method is invoked to allow the parent to increase the size of the
// collectionview that shows which contacts have been selected. To increase or decrease
// the number of rows visible, change the maxVisibleRows property of the MBContactPicker
//- (void)contactPicker:(MBContactPicker*)contactPicker didUpdateContentHeightTo:(CGFloat)newHeight
//{
//    self.pickerHeight.constant = newHeight;
//    [UIView animateWithDuration:contactPicker.animationSpeed animations:^{
//        [self.view layoutIfNeeded];
//    }];
//}

@end
