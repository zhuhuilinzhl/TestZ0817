//
//  ShapeView.m
//  ShapeView iOS
//
//  Created by XDChang on 17/3/1.
//  Copyright © 2017年 XDChang. All rights reserved.
//

/*
 分期付款选择期数
 1、先添加底层一个view（_holeShapeView），在这个View上画出背景layer（包括：一个细长矩形 六个小圆，创建六个节点btn,下标题并添加进数组)，
 方法名：[self drawWholeShape];
 
 2、在self上添加目标视图targetView，充当滑动控制器
    在滑动控制器上添加拖拽手势，并且控制滑动时，只改变控制器的X坐标，Y轴保持不变。
 
 3、绘制绿色layer跟随滑动控制器而动。
 
 4、处理各个按钮的点击事件，让滑动控制器跟绿色layer随之改变。
 
 5、处理细节，吸附功能，点亮下标题，对滑动控制器最小和最大X轴位移的控制。
 
 6、设置代理，在各个方法里触发代理方法。
 
 */

#import "DCSliderView.h"
#define WIDTH self.frame.size.width
#define TITLE @[@"1期",@"2期",@"3期",@"6期",@"9期",@"12期"];
#define TitleLabelNotSelectColor [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]
@interface DCSliderView ()


@property (nonatomic,strong) NSMutableArray *btnArr; // 创建的btn
@property (nonatomic,strong) NSMutableArray *btnOriginXArr;// 每个btn的X坐标
@property (nonatomic,strong) NSMutableArray *btnLayerArr; // 多个圆的绿色layer
@property (nonatomic,strong) NSMutableArray *titleLabelArr; // 标题label数组
@property (nonatomic,assign) float xx; // 圆心系数X
@property (nonatomic,assign) float yy; // 圆心系数Y
@property (nonatomic,assign) float middleGap;//圆之间的中点系数
@end

@implementation DCSliderView
{
    
    
    UIView *_holeShapeView; // 底层灰色背景view
    UIImageView *_targetView; // 大按钮
    UIBezierPath *_recPath; // 创建绿色layer的贝塞尔
    CAShapeLayer *_tubeShape; // 创建绿色layer的ShapeLayer
    CGColorRef K_CGColor; // 滑动过的轨道的颜色 layer的颜色
}



#pragma mark --- 初始化
- (instancetype)initWithFrame:(CGRect)frame WithLayerColor:(UIColor *)CGcolor
{

    self = [super initWithFrame:frame];
    
    if (self) {
        
        K_CGColor = CGcolor.CGColor;
        
        [self initFactor];
        
        [self initNewPath];
        
        [self initHoleShapeView];
        
        [self initTargetView];
        
    }
    return self;

}
#pragma mark --- 初始化各种系数
- (void)initFactor
{

    // 实现各个圆之间的间距逐渐增大，我自己设置了几个参数，大家可以根据自己的实际情况去改变圆之间的间距。不是非要按照这个来，这里只是提供思路。
    // 4,5
    if (WIDTH == 320-20) {
        _xx = 4.0;
        
        _yy = 35.0;
        
        _middleGap = 5.0;
    }// 6
    else if (WIDTH == 375-20)
    {
        _xx = 5.0;
        
        _yy = 40.0;
        
        _middleGap = 6.0;
        
    }// 6+
    else if (WIDTH == 414 -20)
    {
        
        _xx = 6.0;
        
        _yy = 43.0;
        
        _middleGap = 7.0;
    }



}
#pragma mark --- 初始化新路径
- (void)initNewPath
{
    _recPath = [UIBezierPath bezierPath];
    _tubeShape = [[CAShapeLayer alloc]init];
    _tubeShape.strokeColor = K_CGColor;
    _tubeShape.fillColor = K_CGColor;


}

#pragma mark --- init整个底层view
- (void)initHoleShapeView
{

    _holeShapeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    
    [self addSubview:_holeShapeView];
    
    [self drawWholeShape];

}
#pragma mark --- init目标视图targetView
- (void)initTargetView
{
    
    _targetView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -6, 22, 22)];
    _targetView.image = [UIImage imageNamed:@"target"];
    
    _targetView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *imageViewPanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                         action:@selector(panGesture:)];
    
    [_targetView addGestureRecognizer:imageViewPanGesture];
    
    [self addSubview:_targetView];



}

#pragma mark --- targetView的       拖拽手势
/*
 //在移动过程中，UIGestureRecognizerStateChanged 这个状态会调用很多次，在这里面处理绿色细长矩形的绘制，添加或删除绿色小圆layer。 
 
 //在移动结束时，UIGestureRecognizerStateEnded 这个状态只调用一次，在这里处理最终的绿色细长矩形，绿色小圆，下标题的点亮，吸附功能。

 */
- (void)panGesture:(UIPanGestureRecognizer *)gesture
{
    CGFloat y;
    
   
    switch (gesture.state) {
            
            
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"滑动开始");
            CGRect rect = gesture.view.frame;
            y = rect.origin.y ;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            /*在这里面处理绿色细长矩形的绘制，添加或删除绿色小圆layer
             获得添加手势的对象
             获得滑动的距离  包含 x y 移动的数值
             
             locationInView:获取到的是手指点击屏幕实时的坐标点；
             translationInView：获取到的是手指移动后，在相对坐标中的偏移量
             */
            CGPoint point  = [gesture translationInView:gesture.view];
            //NSLog(@"point.x, point.y :%.2f, %.2f", point.x, point.y);
            
            CGRect targetRect = _targetView.frame;
            
            CGFloat targetX = targetRect.origin.x;

           // 绿色的细长矩形
            [_recPath removeAllPoints];// 这个方法会调用很多次，每次调用都会绘制一条路径，为了实现绿色路径跟随滑动控制器而动的效果，所有每次绘制之前都移除掉所有的点，其它地方有这样的处理都是一个道理。
            [_recPath moveToPoint:CGPointMake(8, 5.8)];
            [_recPath addLineToPoint:CGPointMake(8, 7)];
            
            if (targetX>8) {// 避免超出最小范围
                
                [_recPath addLineToPoint:CGPointMake(targetX, 7)];
                [_recPath addLineToPoint:CGPointMake(targetX, 5.8)];
            }
            
            
           
            [_recPath closePath];
            
            _tubeShape.path = _recPath.CGPath;
            [_tubeShape setNeedsDisplay];
            [self.layer addSublayer:_tubeShape];

            //可以屏蔽 start
            NSArray *titleArr = TITLE;
            
            for (int i = 0; i < titleArr.count; i ++) {
                
                if (i!=titleArr.count-1) {
                    // 滑动过程中添加绿色圆layer
                    if (targetX >= [self.btnOriginXArr[i]integerValue] && targetX < [_btnOriginXArr[i+1]integerValue]) {
                        // 删除上一个绿色小圆layer
                        CAShapeLayer *layer = self.btnLayerArr[i+1];
                        
                        if (layer) {
                            [layer removeFromSuperlayer];
                        }
                        // 添加新的绿色小圆layer
                        [_holeShapeView.layer addSublayer:self.btnLayerArr[i]];
                        [_shapeViewDelegate onShapeViewDelegateEventWithString:titleArr[i]];
                    }
                    
                }
                
            }
            // end */
            
            
            
            
            
            //CGRectOffset是以视图的原点为起始 移动 dx x移动距离  dy y移动距离
            // 改变 _targetView 的frame，只改变X，Y坐标保持不变。
            gesture.view.frame =CGRectOffset(gesture.view.frame, point.x, 0);
            
            //清空移动距离
            [gesture setTranslation:CGPointZero inView:gesture.view];
            
//            CGPoint point2  = [gesture translationInView:gesture.view];
//            NSLog(@"point2.x, point2.y :%.2f, %.2f", point2.x, point2.y);
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //这个状态只调用一次，在这里处理最终的绿色细长矩形，下标题的点亮，吸附功能。
//            recPath = [UIBezierPath bezierPath];
            NSLog(@"滑动结束");
            
            CGRect targetRect = _targetView.frame;
            
            CGFloat targetX = targetRect.origin.x;
            
            float btnX = [self.btnOriginXArr.lastObject integerValue];
           // targetView在第一个圆
            if (targetX<0) {
                
                targetRect.origin.x = 0;
                
                _targetView.frame = targetRect;
                
                [_shapeViewDelegate onShapeViewDelegateEventWithString:@"1期"];
                // 改变下标题颜色
                for (UILabel *label in self.titleLabelArr) {
                    
                    label.textColor = TitleLabelNotSelectColor;
                }
                UILabel *firstLabel = self.titleLabelArr.firstObject;
                
                
                firstLabel.textColor = [UIColor colorWithCGColor:K_CGColor];
                break;
            }
            // targetView在最后一个圆
            if (targetX >btnX) {
                
                targetRect.origin.x = btnX;
                
                _targetView.frame = targetRect;
                [_shapeViewDelegate onShapeViewDelegateEventWithString:@"12期"];
                // 改变下标题颜色
                for (UILabel *label in self.titleLabelArr) {
                    
                    label.textColor = TitleLabelNotSelectColor;
                }
                UILabel *firstLabel = self.titleLabelArr.lastObject;
                
                
                firstLabel.textColor = [UIColor colorWithCGColor:K_CGColor];
                break;
            }
            
            NSArray *titleArr = TITLE;
            // targetView 在中间各个圆
            for (int i = 0; i < titleArr.count; i ++) {
                
                if (i!= titleArr.count - 1) {
                   
                    if (targetX >= [self.btnOriginXArr[i]integerValue] && targetX < [_btnOriginXArr[i]integerValue]+15.0 +_middleGap*i) {
                        
                        
                        NSLog(@"%ld",(long)[_btnOriginXArr[i]integerValue]);
                        
                        targetRect.origin.x = [_btnOriginXArr[i]integerValue];
                        _targetView.frame = targetRect;
                        
                        [_shapeViewDelegate onShapeViewDelegateEventWithString:titleArr[i]];
                        
                        for (UILabel *label in self.titleLabelArr) {
                            
                            label.textColor = TitleLabelNotSelectColor;
                        }
                        UILabel *firstLabel = self.titleLabelArr[i];
                        
                        
                        firstLabel.textColor = [UIColor colorWithCGColor:K_CGColor];
                        
                        
                    }
                    else if(targetX >=[_btnOriginXArr[i]integerValue]+10.0 + _middleGap*i)
                    {
                        targetRect.origin.x = [_btnOriginXArr[i+1]integerValue];
                        _targetView.frame = targetRect;
                        [_shapeViewDelegate onShapeViewDelegateEventWithString:titleArr[i+1]];
                        
                        // 改变下标题颜色
                        for (UILabel *label in self.titleLabelArr) {
                            
                            label.textColor = TitleLabelNotSelectColor;
                        }
                        UILabel *firstLabel = self.titleLabelArr[i+1];
                        
                        firstLabel.textColor = [UIColor colorWithCGColor:K_CGColor];
                    
                    }
                    
                }
            
            }
           // // 绿色的细长矩形  先移除贝塞尔所有的点,然后重新绘制贝塞尔路径
            [_recPath removeAllPoints];
            [_recPath moveToPoint:CGPointMake(8, 5.8)];
            [_recPath addLineToPoint:CGPointMake(8, 7)];
            
            [_recPath addLineToPoint:CGPointMake(_targetView.frame.origin.x, 7)];
            [_recPath addLineToPoint:CGPointMake(_targetView.frame.origin.x, 5.8)];
            
            [_recPath closePath];
            
            _tubeShape.path = _recPath.CGPath;
            [_tubeShape setNeedsDisplay];
            [self.layer addSublayer:_tubeShape];
        }
            
            break;
        default:
            break;
    }



}

#pragma mark --- 加载所有的layer
- (void)drawWholeShape
{
    CGFloat gapX = self.frame.origin.x;
    // 管道  用贝塞尔函数画出细长矩形路径
    UIBezierPath *recPath = [UIBezierPath bezierPath];
    
    [recPath moveToPoint:CGPointMake(8, 4)];//上起点
    [recPath addLineToPoint:CGPointMake(8, 8)];//下起点
    [recPath addLineToPoint:CGPointMake(8+WIDTH-2*gapX, 8)];//下结束点
    [recPath addLineToPoint:CGPointMake(8+WIDTH-2*gapX, 4)];//上结束点
    //用CAShapeLayer绘制细长矩形
    CAShapeLayer *tubeShape = [[CAShapeLayer alloc]init];
    
    tubeShape.path = recPath.CGPath;
    // 外边框颜色
    tubeShape.strokeColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    // 内部填充颜色
    tubeShape.fillColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    
    
     [_holeShapeView.layer addSublayer:tubeShape];
    
    NSArray *title = TITLE;
    //for 循环绘制六个灰色小圆跟绿色小圆，创建六个btn,下标题并添加进数组
    for (int i = 0; i <title.count; i ++) {
        
        //可以屏蔽 start
        
        // 圆形 灰色小圆
        UIBezierPath *leftSemiPath1 = [UIBezierPath bezierPath];
        
        CGPoint pointR1 = CGPointMake(12 +(_yy+_xx*i)*i, 6);
        
        [leftSemiPath1 addArcWithCenter:pointR1 radius:6 startAngle:(0.0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
        
        
        CAShapeLayer *leftSemiShape1 = [[CAShapeLayer alloc]init];
        
        leftSemiShape1.path = leftSemiPath1.CGPath;
        
        leftSemiShape1.strokeColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
        leftSemiShape1.fillColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;

        [_holeShapeView.layer addSublayer:leftSemiShape1];
        
        
        // 圆形2  绿色小圆
        UIBezierPath *leftSemiPath2 = [UIBezierPath bezierPath];
        
        CGPoint pointR2 = CGPointMake(12 +(_yy+_xx*i)*i, 6);
        
        [leftSemiPath2 addArcWithCenter:pointR2 radius:4 startAngle:(0.0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
        
        
        CAShapeLayer *leftSemiShape2 = [[CAShapeLayer alloc]init];
        
        leftSemiShape2.path = leftSemiPath2.CGPath;
        
        leftSemiShape2.strokeColor = K_CGColor;
        leftSemiShape2.fillColor = K_CGColor;

        [self.btnLayerArr addObject:leftSemiShape2];
        
        
        if (i==0) {
           // 将第一个绿色小圆添加到底层view上
            [_holeShapeView.layer addSublayer:leftSemiShape2];
        }
        
        //end */
        
        
        
        
        
        float x = 4 +(_yy+_xx*i)*i;
        // 节点按钮
        UIButton *stepBtn = [[UIButton alloc]initWithFrame:CGRectMake(x, -2, 14, 14)];
        
        [_btnArr addObject:stepBtn];
        [self.btnOriginXArr addObject:@(x)];
        
        stepBtn.tag = i;
        
        [stepBtn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stepBtn];
        
        //下标题
        UILabel *qiShuLabel = [[UILabel alloc]init];
        
        qiShuLabel.center = CGPointMake(x-4, 20);
        qiShuLabel.text = title[i];
        qiShuLabel.textColor = TitleLabelNotSelectColor;
        qiShuLabel.font = [UIFont systemFontOfSize:12];
        
        [qiShuLabel sizeToFit];
        
        [self addSubview:qiShuLabel];
        
        [self.titleLabelArr addObject:qiShuLabel];
    }
   
}
#pragma mark --- 按钮点击事件
- (void)onBtnClick:(UIButton *)btn
{
    NSArray *titleArr = TITLE;
    
    [_shapeViewDelegate onShapeViewDelegateEventWithString:titleArr[btn.tag]];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        NSInteger x = [_btnOriginXArr[btn.tag]integerValue];
        CGRect rect = _targetView.frame;
        rect.origin.x = x;
        _targetView.frame = rect;
        
    } completion:^(BOOL finished) {
        // 改变下标题颜色
        for (UILabel *label in self.titleLabelArr) {
            
            label.textColor = TitleLabelNotSelectColor;
        }
        UILabel *firstLabel = self.titleLabelArr[btn.tag];
        
        firstLabel.textColor = [UIColor colorWithCGColor:K_CGColor];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //可以屏蔽 start
        //绿色小圆layer的添加和删除
        for (CAShapeLayer *layer in self.btnLayerArr) {
            
            [layer removeFromSuperlayer];
        }
        
        for (int i = 0; i < btn.tag+1; i ++) {
            [_holeShapeView.layer addSublayer:self.btnLayerArr[i]];
        }
        
        //end */
        
        
        
        
        // 绿色轨道 先移除贝塞尔所有的点,然后重新绘制贝塞尔路径
        [_recPath removeAllPoints];
        [_recPath moveToPoint:CGPointMake(8, 5.8)];
        [_recPath addLineToPoint:CGPointMake(8, 7)];
        
        if (_targetView.frame.origin.x > 8) {
            
            [_recPath addLineToPoint:CGPointMake(_targetView.frame.origin.x, 7)];
            [_recPath addLineToPoint:CGPointMake(_targetView.frame.origin.x, 5.8)];
            
        }
        [_recPath closePath];
        
        _tubeShape.path = _recPath.CGPath;
        [_tubeShape setNeedsDisplay];
        [self.layer addSublayer:_tubeShape];
        
    });
}


#pragma mark --- lazy start loading ---
- (NSMutableArray *)btnArr
{
    if (!_btnArr) {
        
        _btnArr = [[NSMutableArray alloc]init];
    }
    
    return _btnArr;
}

- (NSMutableArray *)btnOriginXArr
{
    if (!_btnOriginXArr) {
        _btnOriginXArr = [[NSMutableArray alloc]init];
    }
    return _btnOriginXArr;
    
}

- (NSMutableArray *)btnLayerArr
{
    if (!_btnLayerArr) {
        
        _btnLayerArr = [[NSMutableArray alloc]init];
    }
    return _btnLayerArr;
    
}

- (NSMutableArray *)titleLabelArr
{
    if (!_titleLabelArr) {
        
        _titleLabelArr = [[NSMutableArray alloc]init];
    }
    return _titleLabelArr;
}

#pragma mark --- lazy end loading ---


@end
