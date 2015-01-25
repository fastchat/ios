// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHUser.h instead.

#import <CoreData/CoreData.h>
#import "CHModel.h"

extern const struct CHUserAttributes {
	__unsafe_unretained NSString *chID;
	__unsafe_unretained NSString *currentUser;
	__unsafe_unretained NSString *doNotDisturb;
	__unsafe_unretained NSString *privateAvatar;
	__unsafe_unretained NSString *sessionToken;
	__unsafe_unretained NSString *username;
} CHUserAttributes;

extern const struct CHUserRelationships {
	__unsafe_unretained NSString *groups;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *pastGroups;
} CHUserRelationships;

@class CHGroup;
@class CHMessage;
@class CHGroup;

@class NSObject;

@interface CHUserID : NSManagedObjectID {}
@end

@interface _CHUser : CHModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CHUserID* objectID;

@property (nonatomic, strong) NSString* chID;

//- (BOOL)validateChID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* currentUser;

@property (atomic) BOOL currentUserValue;
- (BOOL)currentUserValue;
- (void)setCurrentUserValue:(BOOL)value_;

//- (BOOL)validateCurrentUser:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* doNotDisturb;

@property (atomic) BOOL doNotDisturbValue;
- (BOOL)doNotDisturbValue;
- (void)setDoNotDisturbValue:(BOOL)value_;

//- (BOOL)validateDoNotDisturb:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id privateAvatar;

//- (BOOL)validatePrivateAvatar:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* sessionToken;

//- (BOOL)validateSessionToken:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* username;

//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *groups;

- (NSMutableOrderedSet*)groupsSet;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) NSOrderedSet *pastGroups;

- (NSMutableOrderedSet*)pastGroupsSet;

@end

@interface _CHUser (GroupsCoreDataGeneratedAccessors)
- (void)addGroups:(NSOrderedSet*)value_;
- (void)removeGroups:(NSOrderedSet*)value_;
- (void)addGroupsObject:(CHGroup*)value_;
- (void)removeGroupsObject:(CHGroup*)value_;

- (void)insertObject:(CHGroup*)value inGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGroupsAtIndex:(NSUInteger)idx;
- (void)insertGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGroupsAtIndex:(NSUInteger)idx withObject:(CHGroup*)value;
- (void)replaceGroupsAtIndexes:(NSIndexSet *)indexes withGroups:(NSArray *)values;

@end

@interface _CHUser (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(CHMessage*)value_;
- (void)removeMessagesObject:(CHMessage*)value_;

@end

@interface _CHUser (PastGroupsCoreDataGeneratedAccessors)
- (void)addPastGroups:(NSOrderedSet*)value_;
- (void)removePastGroups:(NSOrderedSet*)value_;
- (void)addPastGroupsObject:(CHGroup*)value_;
- (void)removePastGroupsObject:(CHGroup*)value_;

- (void)insertObject:(CHGroup*)value inPastGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPastGroupsAtIndex:(NSUInteger)idx;
- (void)insertPastGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePastGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPastGroupsAtIndex:(NSUInteger)idx withObject:(CHGroup*)value;
- (void)replacePastGroupsAtIndexes:(NSIndexSet *)indexes withPastGroups:(NSArray *)values;

@end

@interface _CHUser (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveChID;
- (void)setPrimitiveChID:(NSString*)value;

- (NSNumber*)primitiveCurrentUser;
- (void)setPrimitiveCurrentUser:(NSNumber*)value;

- (BOOL)primitiveCurrentUserValue;
- (void)setPrimitiveCurrentUserValue:(BOOL)value_;

- (NSNumber*)primitiveDoNotDisturb;
- (void)setPrimitiveDoNotDisturb:(NSNumber*)value;

- (BOOL)primitiveDoNotDisturbValue;
- (void)setPrimitiveDoNotDisturbValue:(BOOL)value_;

- (id)primitivePrivateAvatar;
- (void)setPrimitivePrivateAvatar:(id)value;

- (NSString*)primitiveSessionToken;
- (void)setPrimitiveSessionToken:(NSString*)value;

- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;

- (NSMutableOrderedSet*)primitiveGroups;
- (void)setPrimitiveGroups:(NSMutableOrderedSet*)value;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (NSMutableOrderedSet*)primitivePastGroups;
- (void)setPrimitivePastGroups:(NSMutableOrderedSet*)value;

@end
