//
//  ZXTabBarViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXTabBarViewController.h"

@interface ZXTabBarViewController ()

@end

@implementation ZXTabBarViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        self.delegate = self;
        self.tabBar.translucent = NO;
        NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:RGBCOLOR(51, 51, 51),NSForegroundColorAttributeName,
                                  [UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        [[UINavigationBar appearance] setBarTintColor:RGBCOLOR(250, 250, 250)];
        UITabBarItem *nearItem = [self.tabBar.items objectAtIndex:0];
        UITabBarItem *zhongxinItem = [self.tabBar.items objectAtIndex:1];
        UITabBarItem *sendItem = [self.tabBar.items objectAtIndex:2];
        UITabBarItem *mineItem = [self.tabBar.items objectAtIndex:3];
        nearItem.title = @"周围";
//        nearItem.imageInsets=UIEdgeInsetsMake(0, 0,5, 0);
        nearItem.image = [[UIImage imageNamed:@"near_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nearItem.selectedImage = [[UIImage imageNamed:@"near_ic_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        zhongxinItem.title = @"游戏";
//        zhongxinItem.imageInsets=UIEdgeInsetsMake(6, 0,2, 0);
        zhongxinItem.image = [[UIImage imageNamed:@"game_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        zhongxinItem.selectedImage = [[UIImage imageNamed:@"game_ic_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        sendItem.title = @"传文件";
        sendItem.image = [[UIImage imageNamed:@"send_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        sendItem.selectedImage = [[UIImage imageNamed:@"sent_ic_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        sendItem.imageInsets=UIEdgeInsetsMake(6, 0,-6, 0);
        mineItem.title = @"我的";
        mineItem.image = [[UIImage imageNamed:@"mine_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        mineItem.selectedImage = [[UIImage imageNamed:@"mine_ic_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
