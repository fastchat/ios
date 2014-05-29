//
//  CHMessageTableViewCell.m
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import "CHMessageTableViewCell.h"

@implementation CHMessageTableViewCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    self.backgroundColor = kLightBackgroundColor;
    
    self.messageTextView.layer.cornerRadius = 5.0;
    self.messageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.messageTextView.layer.borderWidth = 0.5;
    self.messageTextView.layer.masksToBounds = YES;
}

@end
