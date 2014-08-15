//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHGroup.h"

@interface CHGroup : _CHGroup

- (NSString *)usernameFromId:(NSString *)theId;
- (CHUser *)memberFromId:(NSString *)theId;
- (BOOL)hasUnread;

@end
