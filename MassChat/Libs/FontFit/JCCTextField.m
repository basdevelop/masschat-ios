//
//  JCCTextField.m
//  JCC
//
//  Created by 聚财村 on 16/10/28.
//  Copyright © 2016年 jucaicun. All rights reserved.
//

#import "JCCTextField.h"

@implementation JCCTextField


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
        [super drawRect:rect];
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, kscreenWidth,44)];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kscreenWidth - 60, 7,50, 30)];
        [button setTitle:@"完成"forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        button.layer.borderColor = [UIColor blueColor].CGColor;
//        button.layer.borderWidth =1;
//        button.layer.cornerRadius =3;
        [bar addSubview:button];
        self.inputAccessoryView = bar;
        
        [button addTarget:self action:@selector(print)forControlEvents:UIControlEventTouchUpInside];
}

- (void) print {
        [self resignFirstResponder];
}


@end
