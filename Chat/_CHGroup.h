// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHGroup.h instead.

#import <CoreData/CoreData.h>
#import "CHModel.h"

extern const struct CHGroupAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *unread;
	__unsafe_unretained NSString *unsentText;
} CHGroupAttributes;

extern const struct CHGroupRelationships {
	__unsafe_unretained NSString *lastMessage;
	__unsafe_unretained NSString *members;
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *pastMembers;
} CHGroupRelationships;

extern const struct CHGroupFetchedProperties {
} CHGroupFetchedProperties;

@class CHMessage;
@class CHUser;
@class CHMessage;
@class CHUser;





@interface CHGroupID : NSManagedObjectID {}
@end

@interface _CHGroup : CHModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CHGroupID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* unread;



@property int16_t unreadValue;
- (int16_t)unreadValue;
- (void)setUnreadValue:(int16_t)value_;

//- (BOOL)validateUnread:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* unsentText;



//- (BOOL)validateUnsentText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CHMessage *lastMessage;

//- (BOOL)validateLastMessage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *members;

- (NSMutableOrderedSet*)membersSet;




@property (nonatomic, strong) NSOrderedSet *messages;

- (NSMutableOrderedSet*)messagesSet;




@property (nonatomic, strong) NSOrderedSet *pastMembers;

- (NSMutableOrderedSet*)pastMembersSet;





@end

@interface _CHGroup (CoreDataGeneratedAccessors)

- (void)addMembers:(NSOrderedSet*)value_;
- (void)removeMembers:(NSOrderedSet*)value_;
- (void)addMembersObject:(CHUser*)value_;
- (void)removeMembersObject:(CHUser*)value_;

- (void)addMessages:(NSOrderedSet*)value_;
- (void)removeMessages:(NSOrderedSet*)value_;
- (void)addMessagesObject:(CHMessage*)value_;
- (void)removeMessagesObject:(CHMessage*)value_;

- (void)addPastMembers:(NSOrderedSet*)value_;
- (void)removePastMembers:(NSOrderedSet*)value_;
- (void)addPastMembersObject:(CHUser*)value_;
- (void)removePastMembersObject:(CHUser*)value_;

@end

@interface _CHGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveUnread;
- (void)setPrimitiveUnread:(NSNumber*)value;

- (int16_t)primitiveUnreadValue;
- (void)setPrimitiveUnreadValue:(int16_t)value_;




- (NSString*)primitiveUnsentText;
- (void)setPrimitiveUnsentText:(NSString*)value;





- (CHMessage*)primitiveLastMessage;
- (void)setPrimitiveLastMessage:(CHMessage*)value;



- (NSMutableOrderedSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitivePastMembers;
- (void)setPrimitivePastMembers:(NSMutableOrderedSet*)value;


@end
