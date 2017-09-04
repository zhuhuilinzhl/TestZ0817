//
//  XLPaymentSuccessHUD.m
//  XLPaymentHUDExample
//
//  Created by MengXianLiang on 2017/4/6.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//


/*
 CAShapeLayer & UIBezierPath & CABasicAnimation
 圆形进度条  模拟音量大小的跳动
 http://www.jianshu.com/p/a641e754ebb6
 
 
 使用CAShapeLayer & UIBezierPath画一些形状
 线段 曲线 动画 简单的柱状图 简单的折线图
 http://www.jianshu.com/p/dd04eac3f42a
 
 */
        
#import "XLPaymentSuccessHUD.h"

static CGFloat lineWidth = 4.0f;
static CGFloat circleDuriation = 0.5f;
static CGFloat checkDuration = 0.2f;

#define BlueColor [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1]

@implementation XLPaymentSuccessHUD {
    CALayer *_animationLayer;
}

//显示
+ (XLPaymentSuccessHUD*)showIn:(UIView*)view {
    [self hideIn:view];
    XLPaymentSuccessHUD *hud = [[XLPaymentSuccessHUD alloc] initWithFrame:view.bounds];
    [hud start];
    [view addSubview:hud];
    return hud;
}

//隐藏
+ (XLPaymentSuccessHUD *)hideIn:(UIView *)view {
    XLPaymentSuccessHUD *hud = nil;
    for (XLPaymentSuccessHUD *subView in view.subviews) {
        if ([subView isKindOfClass:[XLPaymentSuccessHUD class]]) {
            [subView hide];
            [subView removeFromSuperview];
            hud = subView;
        }
    }
    return hud;
}

- (void)start {
    [self circleAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * circleDuriation * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self checkAnimation];
    });
}

- (void)hide {
    for (CALayer *layer in _animationLayer.sublayers) {
        [layer removeAllAnimations];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    _animationLayer = [CALayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 60, 60);
    _animationLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.layer addSublayer:_animationLayer];
}

//关于CAShapeLayer的一些实用案例和技巧  http://www.jianshu.com/p/a1e88a277975
//画圆  这个动画比较简单，是利用贝塞尔曲线画弧的功能。再利用CAShapeLayer的strokeEnd属性加上核心动画实现的圆环动画。
- (void)circleAnimation {
    //显示图层
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = _animationLayer.bounds;
    [_animationLayer addSublayer:circleLayer];
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = BlueColor.CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    
    //运动路径
    CGFloat lineWidth = 5.0f;
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleLayer.position radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    //执行动画
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = circleDuriation;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.delegate = self;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
}

//对号  对号动画是利用了贝塞尔曲线的画线特性，设置了两段曲线拼接成了一个对号。如上图所示对号由线段AB和线段BC拼接完成，然后再利用核心动画和CAShapeLayer的strokeEnd属性实现对号动画。
- (void)checkAnimation {
    
    //外切圆的边长
    CGFloat a = _animationLayer.bounds.size.width;
    
    //设置三个点 A、B、C
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
    [path addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
    [path addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
    
    //显示图层
    CAShapeLayer *checkLayer = [CAShapeLayer layer];
    checkLayer.path = path.CGPath;
    checkLayer.fillColor = [UIColor clearColor].CGColor;
    checkLayer.strokeColor = BlueColor.CGColor;
    checkLayer.lineWidth = lineWidth;
    checkLayer.lineCap = kCALineCapRound;
    checkLayer.lineJoin = kCALineJoinRound;
    [_animationLayer addSublayer:checkLayer];
    
    //执行动画
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = checkDuration;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    checkAnimation.delegate = self;
    [checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
    [checkLayer addAnimation:checkAnimation forKey:nil];
}

@end
