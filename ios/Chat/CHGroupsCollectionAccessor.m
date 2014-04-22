//
//  CHGroupsCollectionAccessor.m
//  Chat
//
//  Created by Michael Caputo on 4/21/14.
//
//

#import "CHGroupsCollectionAccessor.h"
#import "CHGroup.h"

@interface CHGroupsCollectionAccessor ()

@property (nonatomic, strong) NSMutableDictionary *groups;

@end

@implementation CHGroupsCollectionAccessor

+ (CHGroupsCollectionAccessor *)sharedAccessor;
{
    static CHGroupsCollectionAccessor *sharedAccessor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAccessor = [[CHGroupsCollectionAccessor alloc] init];
    });
    
    return sharedAccessor;
}

- (void) addGroupsWithArray:(NSArray *)arrayOfGroups;
{
    if (!self.groups) {
        self.groups = [[NSMutableDictionary alloc] init];
    }
    DLog(@"group is null? %@", self.groups);
    for (CHGroup *group in arrayOfGroups) {
        DLog(@"new group %@", group);
        self.groups[group._id] = group;
    }

    DLog(@"Made global groups: %@", self.groups);


}

- (void) addGroupWithId: (NSString *)groupId group: (CHGroup *)group;
{
    self.groups[groupId] = group;
}

- (CHGroup *) getGroupWithId: (NSString *)groupId;
{
    return self.groups[groupId];
}

- (NSDictionary *) getAllMembersForGroupWithId: (NSString *)groupId;
{
    return ((CHGroup *)self.groups[groupId]).memberDict;
}

@end
