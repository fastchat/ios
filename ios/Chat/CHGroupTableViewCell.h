//
//  CHGroupTableViewCell.h
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import <UIKit/UIKit.h>

@class CHUnreadView;

@interface CHGroupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *groupTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupRightDetailLabel;
@property (nonatomic, strong) CHUnreadView *unreadView;

- (void)setUnread:(BOOL)unread;

@end
