//
//  CHMediaOwnTableViewCell.h
//  Chat
//
//  Created by Michael Caputo on 5/21/14.
//
//

#import <UIKit/UIKit.h>
#import "CHMessageTableViewCell.h"

@interface CHMediaOwnTableViewCell : CHMessageTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mediaMessageImageView;


@property NSDate *dateSent;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
