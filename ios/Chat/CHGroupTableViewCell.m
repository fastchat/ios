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
    if (!_unreadView) {
        self.unreadView = [[CHUnreadView alloc] initWithUnread:NO];
        self.unreadView.center = CGPointMake(8, self.frame.size.height / 2.0);
        [self addSubview:_unreadView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUnread:(BOOL)unread;
{
    _unreadView.unread = unread;
}

@end
