// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHUser.m instead.

#import "_CHUser.h"

const struct CHUserAttributes CHUserAttributes = {
	.privateAvatar = @"privateAvatar",
	.sessionToken = @"sessionToken",
	.username = @"username",
};

const struct CHUserRelationships CHUserRelationships = {
	.groups = @"groups",
	.messages = @"messages",
	.pastGroups = @"pastGroups",
};

const struct CHUserFetchedProperties CHUserFetchedProperties = {
};

@implementation CHUserID
@end

@implementation _CHUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CHUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CHUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CHUser" inManagedObjectContext:moc_];
}

- (CHUserID*)objectID {
	return (CHUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic privateAvatar;






@dynamic sessionToken;






@dynamic username;






@dynamic groups;

	
- (NSMutableOrderedSet*)groupsSet {
	[self willAccessValueForKey:@"groups"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"groups"];
  
	[self didAccessValueForKey:@"groups"];
	return result;
}
	

@dynamic messages;

	
- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];
  
	[self didAccessValueForKey:@"messages"];
	return result;
}
	

@dynamic pastGroups;

	
- (NSMutableOrderedSet*)pastGroupsSet {
	[self willAccessValueForKey:@"pastGroups"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"pastGroups"];
  
	[self didAccessValueForKey:@"pastGroups"];
	return result;
}
	






@end
