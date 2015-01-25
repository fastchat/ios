// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CHMessage.m instead.

#import "_CHMessage.h"

const struct CHMessageAttributes CHMessageAttributes = {
	.authorId = @"authorId",
	.chID = @"chID",
	.groupId = @"groupId",
	.hasMedia = @"hasMedia",
	.hasURLMedia = @"hasURLMedia",
	.mediaHeight = @"mediaHeight",
	.mediaWidth = @"mediaWidth",
	.rowHeight = @"rowHeight",
	.sent = @"sent",
	.text = @"text",
	.theMediaSent = @"theMediaSent",
};

const struct CHMessageRelationships CHMessageRelationships = {
	.author = @"author",
	.group = @"group",
	.groupLastMessage = @"groupLastMessage",
};

@implementation CHMessageID
@end

@implementation _CHMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CHMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CHMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CHMessage" inManagedObjectContext:moc_];
}

- (CHMessageID*)objectID {
	return (CHMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"hasMediaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasMedia"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"hasURLMediaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasURLMedia"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"mediaHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mediaHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"mediaWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mediaWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rowHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rowHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic authorId;

@dynamic chID;

@dynamic groupId;

@dynamic hasMedia;

- (BOOL)hasMediaValue {
	NSNumber *result = [self hasMedia];
	return [result boolValue];
}

- (void)setHasMediaValue:(BOOL)value_ {
	[self setHasMedia:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasMediaValue {
	NSNumber *result = [self primitiveHasMedia];
	return [result boolValue];
}

- (void)setPrimitiveHasMediaValue:(BOOL)value_ {
	[self setPrimitiveHasMedia:[NSNumber numberWithBool:value_]];
}

@dynamic hasURLMedia;

- (BOOL)hasURLMediaValue {
	NSNumber *result = [self hasURLMedia];
	return [result boolValue];
}

- (void)setHasURLMediaValue:(BOOL)value_ {
	[self setHasURLMedia:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasURLMediaValue {
	NSNumber *result = [self primitiveHasURLMedia];
	return [result boolValue];
}

- (void)setPrimitiveHasURLMediaValue:(BOOL)value_ {
	[self setPrimitiveHasURLMedia:[NSNumber numberWithBool:value_]];
}

@dynamic mediaHeight;

- (double)mediaHeightValue {
	NSNumber *result = [self mediaHeight];
	return [result doubleValue];
}

- (void)setMediaHeightValue:(double)value_ {
	[self setMediaHeight:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMediaHeightValue {
	NSNumber *result = [self primitiveMediaHeight];
	return [result doubleValue];
}

- (void)setPrimitiveMediaHeightValue:(double)value_ {
	[self setPrimitiveMediaHeight:[NSNumber numberWithDouble:value_]];
}

@dynamic mediaWidth;

- (double)mediaWidthValue {
	NSNumber *result = [self mediaWidth];
	return [result doubleValue];
}

- (void)setMediaWidthValue:(double)value_ {
	[self setMediaWidth:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveMediaWidthValue {
	NSNumber *result = [self primitiveMediaWidth];
	return [result doubleValue];
}

- (void)setPrimitiveMediaWidthValue:(double)value_ {
	[self setPrimitiveMediaWidth:[NSNumber numberWithDouble:value_]];
}

@dynamic rowHeight;

- (float)rowHeightValue {
	NSNumber *result = [self rowHeight];
	return [result floatValue];
}

- (void)setRowHeightValue:(float)value_ {
	[self setRowHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRowHeightValue {
	NSNumber *result = [self primitiveRowHeight];
	return [result floatValue];
}

- (void)setPrimitiveRowHeightValue:(float)value_ {
	[self setPrimitiveRowHeight:[NSNumber numberWithFloat:value_]];
}

@dynamic sent;

@dynamic text;

@dynamic theMediaSent;

@dynamic author;

@dynamic group;

@dynamic groupLastMessage;

@end

