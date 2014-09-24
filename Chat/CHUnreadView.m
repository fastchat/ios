//
//  CHUnreadView.m
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import "CHUnreadView.h"

#define kSize 12

@interface CHUnreadView ()

@property (nonatomic, strong) UIColor *circleColor;

@end

@implementation CHUnreadView

- (instancetype)initWithUnread:(BOOL)unread;
{
    if ( (self = [super initWithFrame:CGRectMake(0, 0, kSize, kSize)]) ) {
        self.backgroundColor = kLightBackgroundColor;
        self.unread = unread;
        self.circleColor = unread ? kPurpleAppColor : kLightBackgroundColor;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.circleColor = selected ? [UIColor clearColor] : ( _unread ? kPurpleAppColor : self.backgroundColor );
}

- (void)setToColor:(UIColor*)color;
{
    self.circleColor = color;
}

// 12, 12
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextSetFillColor(ctx, CGColorGetComponents(_circleColor.CGColor));
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
