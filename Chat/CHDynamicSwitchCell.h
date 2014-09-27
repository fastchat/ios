//
//  PSSwitchCell.h
//  PhillyBeerScene
//
//  Created by Ethan Mick on 11/5/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHDynamicCell.h"

@interface CHDynamicSwitchCell : CHDynamicCell

@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)toggle;

@end
