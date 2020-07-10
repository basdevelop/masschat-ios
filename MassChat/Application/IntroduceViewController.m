//
//  IntroduceViewController.m
//  MassChat
//
//  Created by wsli on 2017/9/29.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "IntroduceViewController.h"
#import "IntroducePageViewController.h"
#import "ZXTabBarViewController.h"

#define KEY_FOR_APP_VERSION     @"current_app_version"

@interface IntroduceViewController ()<UIPageViewControllerDataSource> {
        NSArray*        _introduceImageNames;
        NSMutableArray* _viewControllers;
}

@end

@implementation IntroduceViewController

- (void)viewDidLoad {
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *version = infoDictionary[@"CFBundleShortVersionString"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* save_version = [defaults stringForKey:KEY_FOR_APP_VERSION];
        
        if (nil == save_version || ![save_version isEqualToString:version]){
                [super viewDidLoad];
                [self viewControllerInit];
                self.dataSource = self;
                [self setViewControllers:@[[_viewControllers objectAtIndex:0]]
                               direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                
                [defaults setObject:version forKey:KEY_FOR_APP_VERSION];
                [defaults synchronize];
                
        }else{
                ZXTabBarViewController *main_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZXTabBarViewController"];
                [UIApplication sharedApplication].delegate.window.rootViewController = main_vc;
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewControllerInit{
         _viewControllers = [NSMutableArray new];
        _introduceImageNames = @[@"introduce_1",@"introduce_2",@"introduce_3",@"introduce_4"];
        
        [_introduceImageNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                IntroducePageViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroducePageViewController"];
                viewController.imageName = _introduceImageNames[idx];
                viewController.view.tag = idx;
                if (idx == 3){
                        [viewController.startAppBtn setHidden:NO];
                }
                [_viewControllers addObject:viewController];
        }];
}

#pragma mark - datasource for uipageview controller delegate.
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
        int current_page_no = (int)viewController.view.tag;
        if (current_page_no == 0){
                return nil;
        }
         return [_viewControllers objectAtIndex:current_page_no - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
        
        int current_page_no = (int)viewController.view.tag + 1;
        if (current_page_no == [_viewControllers count]){
                return nil;
        }
        
        return [_viewControllers objectAtIndex:current_page_no];
}

@end
