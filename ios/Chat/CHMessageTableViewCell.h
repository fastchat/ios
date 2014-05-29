//
//  CHMessageTableViewCell.h
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
