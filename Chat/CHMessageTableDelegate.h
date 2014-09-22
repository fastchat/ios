//
//  CHMessageTableDelegate.h
//  Chat
//
//  Created by Ethan Mick on 9/18/14.
//
//

#import <Foundation/Foundation.h>

@protocol CHMessageTableDelegate;
@class CHGroup, CHMessage;

@interface CHMessageTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<CHMessageTableDelegate> delegate;
@property (nonatomic, strong) CHGroup *group;
@property (nonatomic, strong) NSMutableArray *messages; //no touchy.

- (instancetype)initWithTable:(UITableView *)table group:(CHGroup *)group;
- (void)addMessage:(CHMessage *)foreignMessage;

@end

@protocol CHMessageTableDelegate <NSObject>

@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
