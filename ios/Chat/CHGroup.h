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
@property (nonatomic, copy) NSNumber *unread;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSArray *pastMembers;
@property (nonatomic, copy) NSArray *members;
@property (nonatomic, strong) NSMutableDictionary *memberDict;
@property (nonatomic, strong) CHMessage *lastMessage;

- (NSString *)getGroupName;
- (NSString *)usernameFromId: (NSString *)theId;
- (CHUser *)memberFromId: (NSString *)theId;


@end
