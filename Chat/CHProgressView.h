//
//  CHProgressView.h
//  Chat
//
//  Created by Ethan Mick on 9/7/14.
//
//

#import <UIKit/UIKit.h>

@interface CHProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *progressColor;

+ (instancetype)viewWithFrame:(CGRect)frame;
- (PMKPromise *)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
