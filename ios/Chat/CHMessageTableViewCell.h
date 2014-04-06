//
//  CHMessageTableViewCell.h
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) NSString *message;
@property (weak, nonatomic) NSString *author;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property NSDate *dateSent;

- (id)initWithCoder:(NSCoder *)aDecoder;
@end
