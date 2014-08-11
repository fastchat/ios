//
//  CHGroup.h
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "Mantle/Mantle.h"
#import "CHFastChatObject.h"

@class CHUser, CHMessage;

@interface CHGroup : CHFastChatObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, strong) NSNumber *unread;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *pastMembers;
@property (nonatomic, copy) NSArray *members;
@property (nonatomic, strong) NSMutableDictionary *memberDict;
@property (nonatomic, strong) CHMessage *lastMessage;

- (NSString *)usernameFromId: (NSString *)theId;
- (CHUser *)memberFromId: (NSString *)theId;
- (BOOL)hasUnread;


@end
