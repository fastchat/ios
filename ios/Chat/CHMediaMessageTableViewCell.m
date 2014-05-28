//
//  CHMediaMessageTableViewCell.m
//  Chat
//
//  Created by Michael Caputo on 5/20/14.
//
//

#import "CHMediaMessageTableViewCell.h"
#import "CHMessageViewController.h"


@interface CHMediaMessageTableViewCell ()
@property CHMessageViewController *parentController;
@end

@implementation CHMediaMessageTableViewCell


- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    self.backgroundColor = kLightBackgroundColor;
    
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

-(void)setupGestureWithTableView: (CHMessageViewController *)tableView;
{
    UITapGestureRecognizer *imageTapRecognizer;
    imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyTableWithRecognizer:) ];
    
    [self.mediaMessageImageView addGestureRecognizer:imageTapRecognizer];
    self.mediaMessageImageView.userInteractionEnabled = YES;
    
    self.parentController = tableView;
}

-(void)notifyTableWithRecognizer:(UITapGestureRecognizer *)recognizer;
{
    [self.parentController expandImage:[self.mediaMessageImageView image]];
}


@end
