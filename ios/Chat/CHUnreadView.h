//
//  CHUnreadView.h
//  Chat
//
//  Created by Ethan Mick on 5/28/14.
//
//

#import <UIKit/UIKit.h>

@interface CHUnreadView : UIView

@property (nonatomic, assign) BOOL unread;

- (instancetype)initWithUnread:(BOOL)unread;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
