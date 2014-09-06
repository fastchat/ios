// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHModel.h instead.

#import <CoreData/CoreData.h>


extern const struct CHModelAttributes {
	__unsafe_unretained NSString *chID;
} CHModelAttributes;

extern const struct CHModelRelationships {
} CHModelRelationships;

extern const struct CHModelFetchedProperties {
} CHModelFetchedProperties;




@interface CHModelID : NSManagedObjectID {}
@end

@interface _CHModel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CHModelID*)objectID;





@property (nonatomic, strong) NSString* chID;



//- (BOOL)validateChID:(id*)value_ error:(NSError**)error_;






@end

@interface _CHModel (CoreDataGeneratedAccessors)

@end

@interface _CHModel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChID;
- (void)setPrimitiveChID:(NSString*)value;




@end
