//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHGroup.h"

@interface CHGroup : _CHGroup

@property (nonatomic, strong) NSMutableDictionary *membersDict;

+ (CHGroup *)groupForMessage:(CHMessage *)message;
+ (PMKPromise *)groupWithName:(NSString *)name members:(NSArray *)members;
- (PMKPromise *)remoteMessagesAtPage:(NSInteger)page;

- (BOOL)hasUnread;
- (void)unreadIncrement;

@end
