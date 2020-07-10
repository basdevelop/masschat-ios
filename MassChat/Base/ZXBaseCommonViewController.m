//
//  ZXBaseCommonViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseCommonViewController.h"

@interface ZXBaseCommonViewController ()
{
//        UILabel *description;
        UIImageView *face;
        UITapGestureRecognizer *tap;
}
@end

@implementation ZXBaseCommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
                // Custom initialization
                
        }
        return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}


- (void)setNoDataText:(NSString *)noDataText {
        if (face) {
                [face removeFromSuperview];
                face = nil;
        }
        if (tap) {
                [self.view removeGestureRecognizer:tap];
        }
//        if (description == nil) {
//                description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
//                description.backgroundColor = [UIColor clearColor];
//                description.textAlignment = NSTextAlignmentCenter;
//                description.center = CGPointMake(WIDTH(self.view)/2, HEIGHT(self.view)/2);
//                description.numberOfLines = 2;
//                description.textColor = Gray136;
//                description.text = noDataText;
//                [self.view addSubview:description];
//        }else {
//                description.text = noDataText;
//        }
}

- (void)setHasData:(BOOL)hasData {
        _hasData = hasData;
        
//        if (hasData) {
//                [description removeFromSuperview];
//                description = nil;
//        }
}


#pragma mark -
- (void)setNoInternet:(BOOL)noInternet {
//        _noInternet = noInternet;
//        [self.view removeGestureRecognizer:tap];
//        if (_noInternet ) {
//                [face removeFromSuperview];
//                face = nil;
//                [description removeFromSuperview];
//                description = nil;
//                
//                face = [[UIImageView alloc] initWithImage:mImageByName(@"warning")];
//                face.frame = CGRectMake(0, 0, 25, 25);
//                
//                face.center = CGPointMake(WIDTH(self.view)/2, HEIGHT(self.view)/2);
//                
//                description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 35)];
//                description.font = [UIFont systemFontOfSize:14];
//                description.backgroundColor = RGBCOLOR(240, 242, 190);
//                description.textAlignment = NSTextAlignmentCenter;
//                description.textColor = Gray136;
//                description.text = @"当前网络不可用，请检查你的网络设置";
//                [self.view addSubview:description];
//                [self.view addSubview:face];
//                tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(againGetData)];
//                [self.view addGestureRecognizer:tap];
//                
//        }else {
//                [face removeFromSuperview];
//                face = nil;
//                [description removeFromSuperview];
//                description = nil;
//        }
}

- (void)againGetData {
        [self performSelector:@selector(againFetchData) withObject:nil];
}
-(void)againFetchData
{
        NSLog(@"点击重试");
}
//- (void)viewDidLayoutSubviews {
//        [super viewDidLayoutSubviews];
//        if (_noInternet) {
//                face.center = CGPointMake(30, NavigationBarHeight + 17);
//                description.center = CGPointMake(WIDTH(self.view)/2, NavigationBarHeight + 17);
//        }
//}

@end
