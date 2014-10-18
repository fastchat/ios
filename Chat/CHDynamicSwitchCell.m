//
//  PSSwitchCell.m
//  PhillyBeerScene
//
//  Created by Ethan Mick on 11/5/13.
//  Copyright (c) 2013 CloudMine. All rights reserved.
//

#import "CHDynamicSwitchCell.h"

@interface CHDynamicSwitchCell ()

@end

@implementation CHDynamicSwitchCell

- (NSArray *)propertyNames;
{
    return @[@"cellSwitch.on", @"switchLabel.text", @"indexPath"];
}

- (void)toggle;
{
    [self.cellSwitch setOn:!self.cellSwitch.on animated:YES];
}

- (void)setDelegatesWithObject:(id)object;
{
    self.delegate = object;
    [self.cellSwitch removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.cellSwitch addTarget:self action:@selector(switchTapped:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)switchTapped:(UISwitch *)sender;
{
    if ([self.delegate respondsToSelector:@selector(cell:tapped:)]) {
        [self.delegate cell:self tapped:sender];
    }
}

@end
