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
- (PMKPromise *)addUsers:(NSArray *)users;
- (CHUser *)userFromID:(NSString *)anID;


- (BOOL)hasUnread;
// Empty means only has the user currently in it.
- (BOOL)isEmpty;
- (void)unreadIncrement;
- (void)setTyping:(BOOL)typing;

@end
