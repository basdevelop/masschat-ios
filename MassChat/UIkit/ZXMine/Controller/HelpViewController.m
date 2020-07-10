//
//  HelpViewController.m
//  MassChat
//
//  Created by wsli on 2017/9/9.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        NSString* path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
        NSURL* url = [NSURL fileURLWithPath:path];
        NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
        [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
