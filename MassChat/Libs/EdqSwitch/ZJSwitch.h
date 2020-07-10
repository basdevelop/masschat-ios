//
//  ZJSwitch
//  JCC
//
//  Created by 聚财村 on 16/9/9.
//  Copyright © 2016年 jucaicun. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZJSwitchStyle) {
    ZJSwitchStyleNoBorder,
    ZJSwitchStyleBorder
};

@interface ZJSwitch : UIControl

@property (nonatomic, assign, getter = isOn) BOOL on;

@property (nonatomic, assign) ZJSwitchStyle style;

@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;

@property (nonatomic, strong) UIColor *onTextColor;
@property (nonatomic, strong) UIColor *offTextColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *onText;
@property (nonatomic, strong) NSString *offText;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
