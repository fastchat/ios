// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHModel.m instead.

#import "_CHModel.h"

const struct CHModelAttributes CHModelAttributes = {
	.chID = @"chID",
};

const struct CHModelRelationships CHModelRelationships = {
};

const struct CHModelFetchedProperties CHModelFetchedProperties = {
};

@implementation CHModelID
@end

@implementation _CHModel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CHModel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CHModel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CHModel" inManagedObjectContext:moc_];
}

- (CHModelID*)objectID {
	return (CHModelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic chID;











@end
