//
//  PSSwitchCell.h
//  PhillyBeerScene
//
//  Created by Ethan Mick on 11/5/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDynamicCell.h"

@protocol CHDynamicSwitchDelegate;

@interface CHDynamicSwitchCell : CHDynamicCell

@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id<CHDynamicSwitchDelegate> delegate;

- (void)toggle;

@end

@protocol CHDynamicSwitchDelegate <NSObject>

@optional
- (void)cell:(CHDynamicSwitchCell *)cell tapped:(UISwitch *)tapped;

@end
