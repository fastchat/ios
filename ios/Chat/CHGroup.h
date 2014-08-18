//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "_CHGroup.h"

@interface CHGroup : _CHGroup

+ (CHGroup *)groupForMessage:(CHMessage *)message;
- (NSString *)usernameFromId:(NSString *)theId;
- (CHUser *)memberFromId:(NSString *)theId;
- (BOOL)hasUnread;
- (NSValueTransformer *)lastMessageEntityAttributeTransformer;

@end
