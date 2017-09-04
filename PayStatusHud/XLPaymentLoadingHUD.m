//
//  XLPaymentLoadingHUD.m
//  XLPaymentHUDExample
//
//  Created by MengXianLiang on 2017/4/6.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "XLPaymentLoadingHUD.h"
/*
 http://blog.csdn.net/u013282507/article/details/70208141
 
 http://blog.csdn.net/u013282507/article/details/70211889
 
 
 UIBezierPath + CAShapeLayer + maskLayer 的组合拳非常适合实现一些不规则的视图，像曲线菜单或任务栏，波纹视图，灌水视图等等，
 
 动画黄金搭档:CADisplayLink&CAShapeLayer  http://www.cnblogs.com/weiboyuan/p/6206324.html
 iOS CAShapeLayer仿滴滴的抢单倒计时  http://www.jianshu.com/p/32b286a6935a
 
 前半段: 从-0.5π到π，这一段运动中速度较快；StartAngle不变，始终未-0.5π；EndAngle在匀速上升，一直到π；前半段中圆弧不断变长，最后形成一个3/4的圆。
 
 后半段: 从π到1.5π，这一段运动速度较慢；StartAngle开始变化，从-0.5π变化到1.5π；EndAngle从π变化到1.5π，最后StartAngle和EndAngle重合于1.5π；后半段中圆弧不断变短，最后直至消失。
 */

static CGFloat lineWidth = 4.0f;
#define BlueColor [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1]

@implementation XLPaymentLoadingHUD
{
    CADisplayLink *_link;//负责界面刷新工作
    CAShapeLayer *_animationLayer;//显示圆环
    
    CGFloat _startAngle;//起始角度
    CGFloat _endAngle;//结束角度
    CGFloat _progress;//当前动画进度
}

+(XLPaymentLoadingHUD*)showIn:(UIView*)view{
    [self hideIn:view];
    XLPaymentLoadingHUD *hud = [[XLPaymentLoadingHUD alloc] initWithFrame:view.bounds];
    [hud start];
    [view addSubview:hud];
    return hud;
}

+(XLPaymentLoadingHUD *)hideIn:(UIView *)view{
    XLPaymentLoadingHUD *hud = nil;
    for (XLPaymentLoadingHUD *subView in view.subviews) {
        if ([subView isKindOfClass:[XLPaymentLoadingHUD class]]) {
            [subView hide];
            [subView removeFromSuperview];
            hud = subView;
        }
    }
    return hud;
}

-(void)start{
    _link.paused = false;
}

-(void)hide{
    _link.paused = true;
    _progress = 0;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI{
    _animationLayer = [CAShapeLayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 60, 60);
    _animationLayer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0);
    
    
    _animationLayer.fillColor = [UIColor clearColor].CGColor;
    _animationLayer.strokeColor = BlueColor.CGColor;
    _animationLayer.lineWidth = lineWidth;
    //设置线两头样式
    _animationLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_animationLayer];

    //界面刷新工作由CADisplayLink来完成
    //什么是CADisplayLink  http://www.jianshu.com/p/76f527f3da0d
    //CADisplaylink 及其应用  http://www.jianshu.com/p/8b43af7d81cd
    //从中可以看出, CADisplaylink 是一个计时器对象，可以使用这个对象来保持应用中的绘制与显示刷新的同步。更通俗的讲，电子显示屏都是由一个个像素点构成，要让屏幕显示的内容变化，需要以一定的频率刷新这些像素点的颜色值，系统会在每次刷新时触发 CADisplaylink。
    //在iOS中有很多方法完成定时器的任务，例如 NSTimer、CADisplayLink 和 GCD都可以。
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _link.paused = true;

}

-(void)displayLinkAction{
    _progress += [self speed];
    if (_progress >= 1) {
        _progress = 0;
    }
    [self updateAnimationLayer];
}

-(void)updateAnimationLayer{
    //前半段的运动
    _startAngle = -M_PI_2;
    _endAngle = -M_PI_2 +_progress * M_PI * 2;
    
    //后半段
    if (_endAngle > M_PI) {
        //在结束角运动0.25个圆的时候，起始角运动1个圆
        //整个等式就是为了保证起始角和结束角同时完成整个圆的运动
        CGFloat progress1 = 1 - (1 - _progress)/0.25;
        _startAngle = -M_PI_2 + progress1 * M_PI * 2;
    }
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    CGFloat centerX = _animationLayer.bounds.size.width/2.0f;
    CGFloat centerY = _animationLayer.bounds.size.height/2.0f;
    //http://www.jianshu.com/p/915b02e02943
    /*画圆弧
     center: 圆心坐标
     radius: 圆的半径
     startAngle: 绘制起始点角度
     endAngle: 绘制终点角度
     clockwise: 是否顺时
     */
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:_startAngle endAngle:_endAngle clockwise:true];
    //设置线两头的样式
    path.lineCapStyle = kCGLineCapRound;
    
    _animationLayer.path = path.CGPath;
}

-(CGFloat)speed{
    ////之所以分母是60，是因为iphone屏幕刷新的频率是60Hz，也就是每秒刷新60次，CADisplayLink这个类就是以屏幕刷新的频率调用刷新方法的。
    if (_endAngle > M_PI) {
        return 0.3/60.0f;
    }
    return 2/60.0f;
}

@end
