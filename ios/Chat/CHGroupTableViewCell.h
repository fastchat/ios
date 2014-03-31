//
//  CHGroupTableViewCell.h
//  Chat
//
//  Created by Ethan Mick on 3/31/14.
//
//

#import <UIKit/UIKit.h>

@interface CHGroupTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDetailRightLabel;

@end
