//
//  CHUser.h
//  Chat
//
//  Created by Michael Caputo on 3/23/14.
//
//

#import <Foundation/Foundation.h>

@interface CHUser : NSObject
    @property (strong, atomic) NSString *username;
    @property NSArray *invites;
    @property NSArray *groups;
@end
