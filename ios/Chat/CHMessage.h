//
//  CHMessage.h
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import "CHFastChatObject.h"
#import "CHUser.h"

@interface CHMessage : CHFastChatObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSDate *sent;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *group;

@end
