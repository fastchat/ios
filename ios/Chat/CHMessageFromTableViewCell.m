//
//  CHMessageFromTableViewCell.m
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import "CHMessageFromTableViewCell.h"

@implementation CHMessageFromTableViewCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    self.messageTextView.layer.masksToBounds = YES;
    self.messageTextView.layer.cornerRadius = 5.0;
}

@end
