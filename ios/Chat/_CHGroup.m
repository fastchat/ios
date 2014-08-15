// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHGroup.m instead.

#import "_CHGroup.h"

const struct CHGroupAttributes CHGroupAttributes = {
	.name = @"name",
	.unread = @"unread",
};

const struct CHGroupRelationships CHGroupRelationships = {
	.lastMessage = @"lastMessage",
	.members = @"members",
	.messages = @"messages",
	.pastMembers = @"pastMembers",
};

const struct CHGroupFetchedProperties CHGroupFetchedProperties = {
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
	

	return keyPaths;
}




@dynamic name;






@dynamic unread;






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
