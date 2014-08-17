//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHUser.h"
#import "Promise.h"
#import "Mantle.h"
#import "CHNetworkManager.h"
#import "UIImage+ColorArt.h"


@interface CHUser ()

@property (nonatomic, retain) UIColor * avatarColor;

@end


@implementation CHUser
@synthesize avatarColor;

+ (instancetype)currentUser;
{
    return [CHUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"_id = '%@'", @""]];
}

- (PMKPromise *)remoteGroups;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [[CHNetworkManager sharedManager] getGroups:^(NSArray *groups) {
            if (groups) {
                fulfiller(groups);
            } else {
                rejecter(nil);
            }
        }];
    }];
}

- (PMKPromise *)avatar;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        if (self.privateAvatar) {
            fulfiller(self.privateAvatar);
            return;
        }
        
        [[CHNetworkManager sharedManager] getAvatarOfUser:self.chID callback:^(UIImage *avatar) {
            self.privateAvatar = avatar;
            if (avatar) {
                fulfiller(fulfiller);
            } else {
                rejecter(nil);
            }
        }];
    }];
}

- (void)setAvatar:(UIImage *)avatar;
{
    self.privateAvatar = avatar;
}

- (UIColor *)color;
{
    if (self.avatarColor) {
        return self.avatarColor;
    } else if (self.privateAvatar) {
        SLColorArt *colorArt = [self.privateAvatar colorArt];
        self.avatarColor = colorArt.primaryColor;
        return self.avatarColor;
    } else {
        return [UIColor blackColor];
    }
}


@end
