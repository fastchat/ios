//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHUser.h"
#import "CHGroup.h"
#import "Promise.h"
#import "CHMessage.h"
#import "Mantle.h"
#import "CHNetworkManager.h"
#import "CHSocketManager.h"
#import "UIImage+ColorArt.h"
#import "CHNetworkManager.h"


@interface CHUser ()

@property (nonatomic, retain) UIColor * avatarColor;
@property (nonatomic, retain) NSDate * lastAvatarFetch;

@end


@implementation CHUser

@synthesize avatarColor = _avatarColor;
@synthesize password = _password;

static CHUser *_currentUser = nil;
+ (instancetype)currentUser;
{
    if (!_currentUser) {
        _currentUser = [CHUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"currentUser = YES"]];
        if (_currentUser.sessionToken) {
            [[CHNetworkManager sharedManager] setSessionToken:_currentUser.sessionToken];
        }
    }
    return _currentUser;
}

+ (instancetype)userWithUsername:(NSString *)username password:(NSString *)password;
{
    CHUser *user = [CHUser MR_createEntity];
    user.username = username;
    user.password = password;
    return user;
}

- (PMKPromise *)login;
{
    return [[CHNetworkManager sharedManager] loginWithUser:self].then(^(CHUser *user){
        self.currentUserValue = YES;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return [[CHNetworkManager sharedManager] currentUserProfile];
    });
}

- (PMKPromise *)registr;
{
    return [[CHNetworkManager sharedManager] registerWithUser:self].then(^(NSDictionary *response){
#warning Not done, set last values here
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return self;
    });
}

- (BOOL)isLoggedIn;
{
    return self.sessionToken != nil;
}

- (PMKPromise *)logout;
{
    _currentUser = nil;
    self.currentUserValue = NO;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return [[CHNetworkManager sharedManager] logout];
}

- (PMKPromise *)leaveGroupAtIndex:(NSUInteger)index;
{
    CHGroup *group = self.groups[index];
    [self removeGroupsObject:group];
    [self addPastGroupsObject:group];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return [[CHNetworkManager sharedManager] leaveGroup:group.chID];
}

- (NSOrderedSet *)groups;
{
    NSMutableOrderedSet *unsortedGroups = [self primitiveGroups];
    [unsortedGroups sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sent" ascending:NO]]];
    return unsortedGroups;
}

#pragma mark - Remote Getters

- (PMKPromise *)remoteGroups;
{
    return [[CHNetworkManager sharedManager] currentUserGroups];
}

- (PMKPromise *)avatar;
{
    if (!self.lastAvatarFetch) {
        self.lastAvatarFetch = [NSDate date];
    }
    
    if (self.privateAvatar) {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
            fulfiller(PMKManifold(self, self.privateAvatar));
        }];
    }
    
    return [[CHNetworkManager sharedManager] avatarForUser:self].then(^(UIImage *avatar){
        self.privateAvatar = avatar;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return PMKManifold(self, self.privateAvatar);
    });
}

- (PMKPromise *)avatar:(UIImage *)image;
{
    self.privateAvatar = image;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return [[CHNetworkManager sharedManager] newAvatar:image forUser:self].then(^{
    });
}

- (PMKPromise *)sendMessage:(CHMessage *)message toGroup:(CHGroup *)group;
{
    if (message.hasMediaValue) {
        return [[CHNetworkManager sharedManager] postMediaMessageWithImage:message.theMediaSent groupId:group.chID message:message.text];
        
    } else {
        return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
            [[CHSocketManager sharedManager] sendMessageWithData:@{@"from": self.chID, @"text" : message.text, @"group": group.chID}
                                                  acknowledgement:^(id argsData) {
                                                      NSLog(@"Acknowledgement");
                                                  }];
            fulfiller(nil);
        }];
    }
}

- (void)setAvatar:(UIImage *)avatar;
{
    self.privateAvatar = avatar;
}

- (UIColor *)color;
{
    if (self.avatarColor) {
        return self.avatarColor;
    } else if (self.privateAvatar) {
        SLColorArt *colorArt = [self.privateAvatar colorArt];
        self.avatarColor = colorArt.primaryColor;
        return self.avatarColor;
    } else {
        return [UIColor blackColor];
    }
}

#pragma mark - Mantle / Core Data

- (void)removeGroupsObject:(CHGroup *)value_;
{
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"groups"]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value_];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
        [tmpOrderedSet removeObject:value_];
        [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
    }
}

- (void)addPastGroupsObject:(CHGroup*)value_;
{
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"pastGroups"]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
    [tmpOrderedSet addObject:value_];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
}



@end
