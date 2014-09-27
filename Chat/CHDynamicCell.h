//
//  PSBarCell.h
//  PhillyBeerScene
//
//  Created by Ethan Mick on 10/31/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHDynamicCell : UITableViewCell

- (NSArray *)propertyNames;
- (void)setDelegatesWithObject:(id)object;

@end
