//
//  CHGroupsCollectionAccessor.h
//  Chat
//
//  Created by Michael Caputo on 4/21/14.
//
//

#import <Foundation/Foundation.h>

@class CHGroup;

@interface CHGroupsCollectionAccessor : NSObject

+ (CHGroupsCollectionAccessor *)sharedAccessor;
- (void) addGroupsWithArray:(NSArray *)arrayOfGroups;
- (void) addGroupWithId: (NSString *)groupId group: (CHGroup *)group;
- (CHGroup *) getGroupWithId: (NSString *)groupId;
- (NSDictionary *) getAllMembersForGroupWithId: (NSString *)groupId;

@end
