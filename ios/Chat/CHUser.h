//
//  CHUser.h
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import <Foundation/Foundation.h>
#import "CHFastChatObject.h"

@interface CHUser : CHFastChatObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userId;
@property NSArray *invites;
@property NSArray *groups;

@end
