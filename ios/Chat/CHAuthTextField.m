//
//  CHAuthTextField.m
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import "CHAuthTextField.h"

@implementation CHAuthTextField

- (void)layoutSubviews;
{
    [super layoutSubviews];
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 0.5;
    self.backgroundColor = [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
}

@end
