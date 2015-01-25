// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHMessage.h instead.

#import <CoreData/CoreData.h>
#import "CHModel.h"

extern const struct CHMessageAttributes {
	__unsafe_unretained NSString *authorId;
	__unsafe_unretained NSString *chID;
	__unsafe_unretained NSString *groupId;
	__unsafe_unretained NSString *hasMedia;
	__unsafe_unretained NSString *hasURLMedia;
	__unsafe_unretained NSString *mediaHeight;
	__unsafe_unretained NSString *mediaWidth;
	__unsafe_unretained NSString *rowHeight;
	__unsafe_unretained NSString *sent;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *theMediaSent;
} CHMessageAttributes;

extern const struct CHMessageRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *group;
	__unsafe_unretained NSString *groupLastMessage;
} CHMessageRelationships;

@class CHUser;
@class CHGroup;
@class CHGroup;

@class NSObject;

@interface CHMessageID : NSManagedObjectID {}
@end

@interface _CHMessage : CHModel {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CHMessageID* objectID;

@property (nonatomic, strong) NSString* authorId;

//- (BOOL)validateAuthorId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* chID;

//- (BOOL)validateChID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* groupId;

//- (BOOL)validateGroupId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hasMedia;

@property (atomic) BOOL hasMediaValue;
- (BOOL)hasMediaValue;
- (void)setHasMediaValue:(BOOL)value_;

//- (BOOL)validateHasMedia:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hasURLMedia;

@property (atomic) BOOL hasURLMediaValue;
- (BOOL)hasURLMediaValue;
- (void)setHasURLMediaValue:(BOOL)value_;

//- (BOOL)validateHasURLMedia:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mediaHeight;

@property (atomic) double mediaHeightValue;
- (double)mediaHeightValue;
- (void)setMediaHeightValue:(double)value_;

//- (BOOL)validateMediaHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mediaWidth;

@property (atomic) double mediaWidthValue;
- (double)mediaWidthValue;
- (void)setMediaWidthValue:(double)value_;

//- (BOOL)validateMediaWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rowHeight;

@property (atomic) float rowHeightValue;
- (float)rowHeightValue;
- (void)setRowHeightValue:(float)value_;

//- (BOOL)validateRowHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* sent;

//- (BOOL)validateSent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id theMediaSent;

//- (BOOL)validateTheMediaSent:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CHUser *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CHGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) CHGroup *groupLastMessage;

//- (BOOL)validateGroupLastMessage:(id*)value_ error:(NSError**)error_;

@end

@interface _CHMessage (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAuthorId;
- (void)setPrimitiveAuthorId:(NSString*)value;

- (NSString*)primitiveChID;
- (void)setPrimitiveChID:(NSString*)value;

- (NSString*)primitiveGroupId;
- (void)setPrimitiveGroupId:(NSString*)value;

- (NSNumber*)primitiveHasMedia;
- (void)setPrimitiveHasMedia:(NSNumber*)value;

- (BOOL)primitiveHasMediaValue;
- (void)setPrimitiveHasMediaValue:(BOOL)value_;

- (NSNumber*)primitiveHasURLMedia;
- (void)setPrimitiveHasURLMedia:(NSNumber*)value;

- (BOOL)primitiveHasURLMediaValue;
- (void)setPrimitiveHasURLMediaValue:(BOOL)value_;

- (NSNumber*)primitiveMediaHeight;
- (void)setPrimitiveMediaHeight:(NSNumber*)value;

- (double)primitiveMediaHeightValue;
- (void)setPrimitiveMediaHeightValue:(double)value_;

- (NSNumber*)primitiveMediaWidth;
- (void)setPrimitiveMediaWidth:(NSNumber*)value;

- (double)primitiveMediaWidthValue;
- (void)setPrimitiveMediaWidthValue:(double)value_;

- (NSNumber*)primitiveRowHeight;
- (void)setPrimitiveRowHeight:(NSNumber*)value;

- (float)primitiveRowHeightValue;
- (void)setPrimitiveRowHeightValue:(float)value_;

- (NSDate*)primitiveSent;
- (void)setPrimitiveSent:(NSDate*)value;

- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;

- (id)primitiveTheMediaSent;
- (void)setPrimitiveTheMediaSent:(id)value;

- (CHUser*)primitiveAuthor;
- (void)setPrimitiveAuthor:(CHUser*)value;

- (CHGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(CHGroup*)value;

- (CHGroup*)primitiveGroupLastMessage;
- (void)setPrimitiveGroupLastMessage:(CHGroup*)value;

@end
