//
//  ZXBaseViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseViewController.h"

@interface ZXBaseViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation ZXBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,
                                  [UIFont systemFontOfSize:17], NSFontAttributeName, nil];
        self.navigationController.navigationBar.titleTextAttributes = attributes;
//        [self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
        [super viewWillAppear:animated];
        if (!_hiddenBackBtn) {
                self.navigationItem.leftBarButtonItem = [self backButton];
        }
        
//        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        self.navigationController.navigationBar.translucent = NO;
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
         [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated
{
        [super viewWillDisappear:animated];
        if ([self isMovingFromParentViewController])
        {
                if (self.navigationController.delegate == self)
                {
                        self.navigationController.delegate = nil;
                }
                if (self.navigationController.interactivePopGestureRecognizer.delegate == self)
                {
                        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                }
        }
        
}

- (UIBarButtonItem *)backButton {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 9, 13, 23);
        [button addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"return_ic"] forState:UIControlStateNormal];
        //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        UIBarButtonItem __autoreleasing *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        return item;
}

- (void)clickBack:(id)sender {
        if (self.showMode == EDQPush) {
                [self.navigationController popViewControllerAnimated:YES];
        } else {
                [self dismissViewControllerAnimated:YES completion:NULL];
        }
}

@end
