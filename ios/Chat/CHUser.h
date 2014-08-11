//
//  CHUser.h
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import <Foundation/Foundation.h>
#import "CHFastChatObject.h"

@interface CHUser : CHFastChatObject <MTLManagedObjectSerializing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, strong) UIImage *avatar;

@end
