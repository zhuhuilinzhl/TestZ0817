//
//  ShowPayStatusViewController.m
//  TestZ0817
//
//  Created by 朱 on 2017/8/17.
//  Copyright © 2017年 朱会林. All rights reserved.
//

#import "ShowPayStatusViewController.h"
#import "XLPaymentSuccessHUD.h"
#import "XLPaymentLoadingHUD.h"

@interface ShowPayStatusViewController ()<UIGestureRecognizerDelegate>

@end

@implementation ShowPayStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始支付" style:UIBarButtonItemStylePlain target:self action:@selector(showLoadingAnimation)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"支付完成" style:UIBarButtonItemStylePlain target:self action:@selector(showSuccessAnimation)];
    
    
    [self createRoundLabel];
}

//通过 贝赛尔曲线生成带圆角的label
- (void)createRoundLabel {
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(100, 400, 100, 50)];
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.path = [UIBezierPath bezierPathWithRoundedRect:lab.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)].CGPath;
    lab.layer.mask = mask;
    lab.backgroundColor = [UIColor redColor];
    [self.view addSubview:lab];
}



-(void)showLoadingAnimation{
    
    self.title = @"正在付款...";
    
    //隐藏支付完成动画
    [XLPaymentSuccessHUD hideIn:self.view];
    //显示支付中动画
    [XLPaymentLoadingHUD showIn:self.view];
}

-(void)showSuccessAnimation{
    
    self.title = @"付款完成";
    
    //隐藏支付中成动画
    [XLPaymentLoadingHUD hideIn:self.view];
    //显示支付完成动画
    [XLPaymentSuccessHUD showIn:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
