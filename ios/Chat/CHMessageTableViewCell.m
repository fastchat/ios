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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    DLog(@"initWithCoder");
    if ( ( self = [super initWithCoder:aDecoder]) ) {
        // Initialization code
        self.authorLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc]init];
        
        self.authorLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.authorLabel];
      //  [self.contentView addSubview:self.messageLabel];
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
   /* DLog(@"layoutSubview");
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    //frame= CGRectMake(boundsX+10 ,0, 50, 50);
    //myImageView.frame = frame;
    
    frame= CGRectMake(boundsX ,20, 50, 25);
    self.authorLabel.frame = frame;
    
    frame= CGRectMake(boundsX+50 ,20, 300, 25);
    self.messageLabel.frame = frame;
 */
}

@end
