//
//  PSSubtextCell.h
//  PhillyBeerScene
//
//  Created by Ethan Mick on 10/31/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDynamicCell.h"

@interface CHDynamicSubtextCell : CHDynamicCell

@property (weak, nonatomic) IBOutlet UILabel *subtextLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleMainLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@end
