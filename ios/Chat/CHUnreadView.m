//
//  CHUnreadView.m
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import "CHUnreadView.h"

#define kSize 12

@implementation CHUnreadView

- (instancetype)initWithUnread:(BOOL)unread;
{
    if ( (self = [super initWithFrame:CGRectMake(0, 0, kSize, kSize)]) ) {
        self.backgroundColor = kLightBackgroundColor;
        self.unread = unread;
    }
    return self;
}

// 12, 12
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextSetFillColor(ctx, CGColorGetComponents(_unread ? [kPurpleAppColor CGColor] : [kLightBackgroundColor CGColor]));
    CGContextFillPath(ctx);
}

- (void)setUnread:(BOOL)unread;
{
    if (_unread != unread) {
        _unread = unread;
        [self setNeedsDisplay];
    }
}


@end
