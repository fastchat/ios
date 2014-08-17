// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHUser.h instead.

#import <CoreData/CoreData.h>
#import "CHModel.h"

extern const struct CHUserAttributes {
	__unsafe_unretained NSString *privateAvatar;
	__unsafe_unretained NSString *sessionToken;
	__unsafe_unretained NSString *username;
} CHUserAttributes;

extern const struct CHUserRelationships {
	__unsafe_unretained NSString *groups;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *pastGroups;
} CHUserRelationships;

extern const struct CHUserFetchedProperties {
} CHUserFetchedProperties;

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
- (CHUserID*)objectID;





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

@interface _CHUser (CoreDataGeneratedAccessors)

- (void)addGroups:(NSOrderedSet*)value_;
- (void)removeGroups:(NSOrderedSet*)value_;
- (void)addGroupsObject:(CHGroup*)value_;
- (void)removeGroupsObject:(CHGroup*)value_;

- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(CHMessage*)value_;
- (void)removeMessagesObject:(CHMessage*)value_;

- (void)addPastGroups:(NSOrderedSet*)value_;
- (void)removePastGroups:(NSOrderedSet*)value_;
- (void)addPastGroupsObject:(CHGroup*)value_;
- (void)removePastGroupsObject:(CHGroup*)value_;

@end

@interface _CHUser (CoreDataGeneratedPrimitiveAccessors)


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
