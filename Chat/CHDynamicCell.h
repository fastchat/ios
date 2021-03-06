//
//  PSBarCell.h
//  PhillyBeerScene
//
//  Created by Ethan Mick on 10/31/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDynamicCell : UITableViewCell

- (void)setCellValues:(NSDictionary *)values withOwner:(id)owner;

- (NSArray *)propertyNames;
- (void)setDelegatesWithObject:(id)object;

@end
