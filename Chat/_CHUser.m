// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHUser.m instead.

#import "_CHUser.h"

const struct CHUserAttributes CHUserAttributes = {
	.chID = @"chID",
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

@dynamic chID;

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

@implementation _CHUser (GroupsCoreDataGeneratedAccessors)
- (void)addGroups:(NSOrderedSet*)value_ {
	[self.groupsSet unionOrderedSet:value_];
}
- (void)removeGroups:(NSOrderedSet*)value_ {
	[self.groupsSet minusOrderedSet:value_];
}
- (void)addGroupsObject:(CHGroup*)value_ {
	[self.groupsSet addObject:value_];
}
- (void)removeGroupsObject:(CHGroup*)value_ {
	[self.groupsSet removeObject:value_];
}
- (void)insertObject:(CHGroup*)value inGroupsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"groups"];
}
- (void)removeObjectFromGroupsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
}
- (void)insertGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"groups"];
}
- (void)removeGroupsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"groups"];
}
- (void)replaceObjectInGroupsAtIndex:(NSUInteger)idx withObject:(CHGroup*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"groups"];
}
- (void)replaceGroupsAtIndexes:(NSIndexSet *)indexes withGroups:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"groups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self groups]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"groups"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"groups"];
}
@end

@implementation _CHUser (PastGroupsCoreDataGeneratedAccessors)
- (void)addPastGroups:(NSOrderedSet*)value_ {
	[self.pastGroupsSet unionOrderedSet:value_];
}
- (void)removePastGroups:(NSOrderedSet*)value_ {
	[self.pastGroupsSet minusOrderedSet:value_];
}
- (void)addPastGroupsObject:(CHGroup*)value_ {
	[self.pastGroupsSet addObject:value_];
}
- (void)removePastGroupsObject:(CHGroup*)value_ {
	[self.pastGroupsSet removeObject:value_];
}
- (void)insertObject:(CHGroup*)value inPastGroupsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
}
- (void)removeObjectFromPastGroupsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastGroups"];
}
- (void)insertPastGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastGroups"];
}
- (void)removePastGroupsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastGroups"];
}
- (void)replaceObjectInPastGroupsAtIndex:(NSUInteger)idx withObject:(CHGroup*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastGroups"];
}
- (void)replacePastGroupsAtIndexes:(NSIndexSet *)indexes withPastGroups:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastGroups"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastGroups]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastGroups"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastGroups"];
}
@end

