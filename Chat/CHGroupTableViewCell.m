//
//  CHGroupTableViewCell.m
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import "CHGroupTableViewCell.h"
#import "CHUnreadView.h"

@implementation CHGroupTableViewCell


- (void)awakeFromNib
{
    self.backgroundColor = kLightBackgroundColor;
    if (!_unreadView) {
        self.unreadView = [[CHUnreadView alloc] initWithUnread:NO];
        self.unreadView.center = CGPointMake(8, self.frame.size.height / 2.0);
        [self addSubview:_unreadView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [_unreadView setSelected:selected animated:animated];
    [super setSelected:selected animated:animated];
}

- (void)setUnread:(BOOL)unread;
{
    _unreadView.unread = unread;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    self.groupDetailLabel.backgroundColor = backgroundColor;
    self.groupTextLabel.backgroundColor = backgroundColor;
    self.groupRightDetailLabel.backgroundColor = backgroundColor;
    self.unreadView.backgroundColor = backgroundColor;
}

@end
