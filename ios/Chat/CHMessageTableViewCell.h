//
//  CHMessageTableViewCell.h
//  Chat
//
//  Created by Michael Caputo on 3/29/14.
//
//

#import <UIKit/UIKit.h>

@interface CHMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) NSString *message;
@property (weak, nonatomic) NSString *author;
@property NSDate *dateSent;

@end
