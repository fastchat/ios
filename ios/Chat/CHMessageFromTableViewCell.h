//
//  CHMessageFromTableViewCell.h
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageFromTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
