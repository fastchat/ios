//
//  CHTextField.m
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import "CHTextField.h"

@implementation CHTextField

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ( (self = [super initWithCoder:aDecoder]) ) {
        self.textInsets = [self defaultInsets];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textInsets = [self defaultInsets];
    }
    return self;
}

// UIEdgeInsetsMake(top, left, bottom, right)
- (UIEdgeInsets)defaultInsets;
{
    return UIEdgeInsetsMake(0, 5, 0, 2);
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds;
{
    return UIEdgeInsetsInsetRect(bounds, _textInsets);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds;
{
    return UIEdgeInsetsInsetRect(bounds, _textInsets);
}

@end
