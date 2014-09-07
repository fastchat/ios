//
//  CHProgressView.m
//  Chat
//
//  Created by Ethan Mick on 9/7/14.
//
//

#import "CHProgressView.h"
#import "UIView+PromiseKit.h"

@interface CHProgressView ()

@property (nonatomic, strong) UIView *progressBar;

@end

@implementation CHProgressView

+ (instancetype)viewWithFrame:(CGRect)frame;
{
    return [[CHProgressView alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame;
{
    if ((self = [super initWithFrame:frame])) {
        self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * _progress, self.frame.size.height)];
        self.progress = 0.01; //default
        [self addSubview:_progressBar];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress;
{
    _progress = MIN(MAX(progress, 0.0), 1.0);
    _progressBar.frame = CGRectMake(0, 0, self.frame.size.width * _progress, self.frame.size.height);
    [self layoutSubviews];
}

- (void)setProgressColor:(UIColor *)progressColor;
{
    if (_progressColor != progressColor) {
        _progressColor = progressColor;
        self.progressBar.backgroundColor = _progressColor;
    }
}

- (PMKPromise *)setProgress:(CGFloat)progress animated:(BOOL)animated;
{
    return [UIView promiseWithDuration:0.7
                                 delay:0.0
                               options:0
                    keyframeAnimations:^{
                        self.progressBar.frame = CGRectMake(self.progressBar.frame.origin.x,
                                                            self.progressBar.frame.origin.y,
                                                            self.frame.size.width * progress,
                                                            self.progressBar.frame.size.height);
                    }].then(^{
//                        _progress = MIN(MAX(progress, 0.01), 1.0);
                    });
}

@end
