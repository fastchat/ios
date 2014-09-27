// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHUser.m instead.

#import "_CHUser.h"

const struct CHUserAttributes CHUserAttributes = {
	.currentUser = @"currentUser",
	.doNotDisturb = @"doNotDisturb",
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
	
	if ([key isEqualToString:@"currentUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"currentUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"doNotDisturbValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"doNotDisturb"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic currentUser;



- (BOOL)currentUserValue {
	NSNumber *result = [self currentUser];
	return [result boolValue];
}

- (void)setCurrentUserValue:(BOOL)value_ {
	[self setCurrentUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCurrentUserValue {
	NSNumber *result = [self primitiveCurrentUser];
	return [result boolValue];
}

- (void)setPrimitiveCurrentUserValue:(BOOL)value_ {
	[self setPrimitiveCurrentUser:[NSNumber numberWithBool:value_]];
}





@dynamic doNotDisturb;



- (BOOL)doNotDisturbValue {
	NSNumber *result = [self doNotDisturb];
	return [result boolValue];
}

- (void)setDoNotDisturbValue:(BOOL)value_ {
	[self setDoNotDisturb:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDoNotDisturbValue {
	NSNumber *result = [self primitiveDoNotDisturb];
	return [result boolValue];
}

- (void)setPrimitiveDoNotDisturbValue:(BOOL)value_ {
	[self setPrimitiveDoNotDisturb:[NSNumber numberWithBool:value_]];
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
