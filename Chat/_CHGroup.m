// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHGroup.m instead.

#import "_CHGroup.h"

const struct CHGroupAttributes CHGroupAttributes = {
	.chID = @"chID",
	.name = @"name",
	.unread = @"unread",
	.unsentText = @"unsentText",
};

const struct CHGroupRelationships CHGroupRelationships = {
	.lastMessage = @"lastMessage",
	.members = @"members",
	.messages = @"messages",
	.pastMembers = @"pastMembers",
};

@implementation CHGroupID
@end

@implementation _CHGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CHGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CHGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CHGroup" inManagedObjectContext:moc_];
}

- (CHGroupID*)objectID {
	return (CHGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"unreadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"unread"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic chID;

@dynamic name;

@dynamic unread;

- (int16_t)unreadValue {
	NSNumber *result = [self unread];
	return [result shortValue];
}

- (void)setUnreadValue:(int16_t)value_ {
	[self setUnread:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUnreadValue {
	NSNumber *result = [self primitiveUnread];
	return [result shortValue];
}

- (void)setPrimitiveUnreadValue:(int16_t)value_ {
	[self setPrimitiveUnread:[NSNumber numberWithShort:value_]];
}

@dynamic unsentText;

@dynamic lastMessage;

@dynamic members;

- (NSMutableOrderedSet*)membersSet {
	[self willAccessValueForKey:@"members"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"members"];

	[self didAccessValueForKey:@"members"];
	return result;
}

@dynamic messages;

- (NSMutableOrderedSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic pastMembers;

- (NSMutableOrderedSet*)pastMembersSet {
	[self willAccessValueForKey:@"pastMembers"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"pastMembers"];

	[self didAccessValueForKey:@"pastMembers"];
	return result;
}

@end

@implementation _CHGroup (MembersCoreDataGeneratedAccessors)
- (void)addMembers:(NSOrderedSet*)value_ {
	[self.membersSet unionOrderedSet:value_];
}
- (void)removeMembers:(NSOrderedSet*)value_ {
	[self.membersSet minusOrderedSet:value_];
}
- (void)addMembersObject:(CHUser*)value_ {
	[self.membersSet addObject:value_];
}
- (void)removeMembersObject:(CHUser*)value_ {
	[self.membersSet removeObject:value_];
}
- (void)insertObject:(CHUser*)value inMembersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"members"];
}
- (void)removeObjectFromMembersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"members"];
}
- (void)insertMembers:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"members"];
}
- (void)removeMembersAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"members"];
}
- (void)replaceObjectInMembersAtIndex:(NSUInteger)idx withObject:(CHUser*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"members"];
}
- (void)replaceMembersAtIndexes:(NSIndexSet *)indexes withMembers:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"members"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self members]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"members"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"members"];
}
@end

@implementation _CHGroup (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSOrderedSet*)value_ {
	[self.messagesSet unionOrderedSet:value_];
}
- (void)removeMessages:(NSOrderedSet*)value_ {
	[self.messagesSet minusOrderedSet:value_];
}
- (void)addMessagesObject:(CHMessage*)value_ {
	[self.messagesSet addObject:value_];
}
- (void)removeMessagesObject:(CHMessage*)value_ {
	[self.messagesSet removeObject:value_];
}
- (void)insertObject:(CHMessage*)value inMessagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"messages"];
}
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"messages"];
}
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"messages"];
}
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"messages"];
}
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(CHMessage*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"messages"];
}
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"messages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self messages]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"messages"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"messages"];
}
@end

@implementation _CHGroup (PastMembersCoreDataGeneratedAccessors)
- (void)addPastMembers:(NSOrderedSet*)value_ {
	[self.pastMembersSet unionOrderedSet:value_];
}
- (void)removePastMembers:(NSOrderedSet*)value_ {
	[self.pastMembersSet minusOrderedSet:value_];
}
- (void)addPastMembersObject:(CHUser*)value_ {
	[self.pastMembersSet addObject:value_];
}
- (void)removePastMembersObject:(CHUser*)value_ {
	[self.pastMembersSet removeObject:value_];
}
- (void)insertObject:(CHUser*)value inPastMembersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastMembers"];
}
- (void)removeObjectFromPastMembersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastMembers"];
}
- (void)insertPastMembers:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pastMembers"];
}
- (void)removePastMembersAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pastMembers"];
}
- (void)replaceObjectInPastMembersAtIndex:(NSUInteger)idx withObject:(CHUser*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastMembers"];
}
- (void)replacePastMembersAtIndexes:(NSIndexSet *)indexes withPastMembers:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastMembers"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pastMembers]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pastMembers"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pastMembers"];
}
@end

