//
//  CHMessageTableDelegate.h
//  Chat
//
//  Created by Ethan Mick on 9/18/14.
//
//

#import <Foundation/Foundation.h>

@class CHGroup;

@interface CHMessageTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) CHGroup *group;

- (instancetype)initWithTable:(UITableView *)table;

@end
