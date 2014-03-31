//
//  CHGroupTableViewCell.m
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import "CHGroupTableViewCell.h"

@implementation CHGroupTableViewCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    self.groupImageView.layer.cornerRadius = self.groupImageView.frame.size.width / 2.0;
    self.groupImageView.layer.masksToBounds = YES;
}

@end
