//
//  CHRefreshView.m
//  Chat
//
//  Created by Ethan Mick on 9/28/14.
//
//

#import "CHRefreshView.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const MRActivityIndicatorViewSpinAnimationKey = @"MRActivityIndicatorViewSpinAnimationKey";

@interface CHRefreshView ()

@property (nonatomic, weak) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CHRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit;
{
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.borderWidth = 0;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.strokeColor = kPurpleAppColor.CGColor;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    if (ABS(frame.size.width - frame.size.height) < CGFLOAT_MIN) {
        // Ensure that we have a square frame
        CGFloat s = MIN(frame.size.width, frame.size.height);
        frame.size.width = s;
        frame.size.height = s;
    }
    
    self.shapeLayer.frame = frame;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

#pragma mark - Notifications

- (void)registerForNotificationCenter {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterFromNotificationCenter {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self];
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [self removeAnimation];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    if (self.isAnimating) {
        [self addAnimation];
    }
}

- (UIBezierPath *)layoutPath;
{
    const double TWO_M_PI = 2.0*M_PI;
    double startAngle = 0.75 * TWO_M_PI;
    double endAngle = startAngle + TWO_M_PI * 0.9;
    
    CGFloat width = self.bounds.size.width;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f)
                                          radius:width/2.2f
                                      startAngle:startAngle
                                        endAngle:endAngle
                                       clockwise:YES];
}

- (void)addAnimation;
{
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue        = @(1*2*M_PI);
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    spinAnimation.duration       = 1.0;
    spinAnimation.repeatCount    = INFINITY;
    [self.shapeLayer addAnimation:spinAnimation forKey:MRActivityIndicatorViewSpinAnimationKey];
}

- (void)startAnimating;
{
    if (_animating) {
        return;
    }
    
    _animating = YES;
    [self registerForNotificationCenter];
    [self addAnimation];
}

- (void)stopAnimating;
{
    if (!_animating) {
        return;
    }
    
    _animating = NO;
    
    [self unregisterFromNotificationCenter];
    [self removeAnimation];
}

- (BOOL)isAnimating;
{
    return _animating;
}

- (void)removeAnimation {
    [self.shapeLayer removeAnimationForKey:MRActivityIndicatorViewSpinAnimationKey];
}

@end
