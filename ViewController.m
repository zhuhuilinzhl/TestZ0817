//
//  ViewController.m
//  TestZ0817
//
//  Created by 朱 on 2017/8/17.
//  Copyright © 2017年 朱会林. All rights reserved.
//

#import "ViewController.h"
#import "XHStarRateView.h"
#import "FenQiSliderViewController.h"
#import "ShowPayStatusViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //评论星星
    [self createStarRateView];
}



- (void)createStarRateView {
    XHStarRateView *starView = [[XHStarRateView alloc]initWithFrame:CGRectMake(50, 100, 35*5+30, 35) numberOfStars:4 rateStyle:IncompleteStar isAnination:NO finish:^(CGFloat currentScore) {
        
    }];
    
    starView.isNeedPan = YES;
    [self.view addSubview:starView];
    starView.currentScore = 3.5;
    
    
    
    for (int i = 0; i < 2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(100, 100+50+i*80, 70, 40);
        [btn setTitle:[NSString stringWithFormat:@"第%d页", i+2] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(handleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    

}

- (void)handleBtnAction:(UIButton *)sender {
    if (sender.tag == 0) {
        FenQiSliderViewController *vc = [[FenQiSliderViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        ShowPayStatusViewController *vc = [[ShowPayStatusViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
