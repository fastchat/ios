//
//  CHCircleImageView.m
//  Chat
//
//  Created by Michael Caputo on 4/11/14.
//
//

#import "CHCircleImageView.h"

@implementation CHCircleImageView

-(void) layoutSubviews;
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.width / 2.0;
    self.layer.masksToBounds = YES;
}

@end
