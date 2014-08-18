//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHMessage.h"
#import "CHGroup.h"
#import "CHUser.h"

@interface CHMessage ()

// Private interface goes here.

@end


@implementation CHMessage

@synthesize groupId = _groupId;

- (void)setAuthorId:(NSString *)authorId;
{
    [self setPrimitiveAuthorId:authorId];
    [self setPrimitiveAuthor:[CHUser MR_findFirstByAttribute:CORE_DATA_ID withValue:authorId]];
}

- (void)setGroupId:(NSString *)groupId;
{
    [self setPrimitiveGroup:[CHGroup MR_findFirstByAttribute:CORE_DATA_ID withValue:groupId]];
}

@end
