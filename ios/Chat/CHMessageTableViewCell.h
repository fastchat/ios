//
//  CHMessageTableViewCell.h
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@property NSDate *dateSent;

- (id)initWithCoder:(NSCoder *)aDecoder;
@end
