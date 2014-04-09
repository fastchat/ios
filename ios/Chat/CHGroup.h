//
//  CHGroup.h
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "Mantle/Mantle.h"
#import "CHFastChatObject.h"

@interface CHGroup : CHFastChatObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSArray *pastMembers;
@property (nonatomic, copy) NSArray *members;

- (NSString *)getGroupName;

@end
