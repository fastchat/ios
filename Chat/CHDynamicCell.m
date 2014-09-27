//
//  PSBarCell.m
//  PhillyBeerScene
//
//  Created by Ethan Mick on 10/31/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import "CHDynamicCell.h"

@implementation CHDynamicCell

- (NSArray *)propertyNames;
{
    return @[];
}

- (void)setDelegatesWithObject:(id)object;
{
    
}

- (void)setCellValues:(NSDictionary *)values withOwner:(id)owner;
{
    NSArray *properties = [self propertyNames];
    
    for (NSString *property in properties) {
        NSString *value = values[property];
        [self setValue:value forKeyPath:property];
    }
    self.accessoryType = [values[@"accessoryOption"] integerValue];
    [self setDelegatesWithObject:owner];
}

@end
