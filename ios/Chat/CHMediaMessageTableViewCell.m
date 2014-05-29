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

- (void)setupGestureWithTableView:(CHMessageViewController *)tableView;
{
    UITapGestureRecognizer *imageTapRecognizer;
    imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifyTableWithRecognizer:) ];
    
    [self.mediaMessageImageView addGestureRecognizer:imageTapRecognizer];
    self.mediaMessageImageView.userInteractionEnabled = YES;
    
    self.parentController = tableView;
}

- (void)notifyTableWithRecognizer:(UITapGestureRecognizer *)recognizer;
{
    [self.parentController expandImage:[self.mediaMessageImageView image]];
}


@end
