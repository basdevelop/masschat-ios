//
//  IntroducePageViewController.m
//  MassChat
//
//  Created by wsli on 2017/9/29.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "IntroducePageViewController.h"
#import "ZXTabBarViewController.h"

@interface IntroducePageViewController ()

@end

@implementation IntroducePageViewController
@synthesize imageName;
- (void)viewDidLoad {
        [super viewDidLoad];
        self.introduceImage.image = [UIImage imageNamed:self.imageName];
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

- (IBAction)pushToMainAction:(UIButton *)sender {
        ZXTabBarViewController *main_vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZXTabBarViewController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = main_vc;
}
@end
