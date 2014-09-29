//
//  CHRefreshTableViewCell.m
//  Chat
//
//  Created by Ethan Mick on 9/28/14.
//
//

#import "CHRefreshTableViewCell.h"
#import "CHRefreshView.h"

@implementation CHRefreshTableViewCell

- (void)awakeFromNib;
{
    [super awakeFromNib];
    self.backgroundColor = kLightBackgroundColor;
    [self.refreshView startAnimating];
}



@end
