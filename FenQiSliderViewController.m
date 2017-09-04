//
//  FenQiSliderViewController.m
//  TestZ0817
//
//  Created by 朱 on 2017/8/17.
//  Copyright © 2017年 朱会林. All rights reserved.
//

#import "FenQiSliderViewController.h"
#import "DCSliderView.h"

@interface FenQiSliderViewController ()<ShapeViewDelegate>
@property (nonatomic, strong)UILabel *qiShuLabel;
@end

@implementation FenQiSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //分期付款
    [self createSliderView];
    
}


- (void)createSliderView {
    // 1.
    DCSliderView *shapeView = [[DCSliderView alloc]initWithFrame:CGRectMake(10, 120, self.view.frame.size.width -20, 30) WithLayerColor:[UIColor colorWithRed:0/255.0 green:210/255.0 blue:87/255.0 alpha:1]];
    
    // 2.
    shapeView.shapeViewDelegate = self;
    
    //3.
    [self.view addSubview:shapeView];
    
    
    _qiShuLabel = [[UILabel alloc]init];
    
    _qiShuLabel.center = CGPointMake(self.view.frame.size.width/2-30, 160);
    
    _qiShuLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    
    _qiShuLabel.font = [UIFont systemFontOfSize:14];
    
    _qiShuLabel.text = @"1期" ;
    [_qiShuLabel sizeToFit];
    
    [self.view addSubview:_qiShuLabel];
}

// 4.
- (void)onShapeViewDelegateEventWithString:(NSString *)str
{
    
    _qiShuLabel.text = str ;
    [_qiShuLabel sizeToFit];
    
    
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
