//
//  CHMessageTableViewCell.m
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import "CHMessageTableViewCell.h"

@implementation CHMessageTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    
    self.messageTextView.layer.cornerRadius = 5.0;
    self.messageTextView.layer.masksToBounds = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if ( ( self = [super initWithCoder:aDecoder]) ) {
        // Initialization code
        self.authorLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc]init];
        
        self.authorLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.authorLabel];
    }
    return self;
}

@end
