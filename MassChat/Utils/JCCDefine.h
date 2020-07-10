//
//  AppDelegate.m
//  EDQFirm
//
//  Created by 聚财村 on 16/6/1.
//  Copyright © 2016年 e贷圈企业版. All rights reserved.
//


#ifndef DAX_JRFAppDefine_h
#define DAX_JRFAppDefine_h

#if __has_feature(objc_arc)
#define mRelease(obj)   obj = nil;
#define mRetainProperty   @property (nonatomic, strong)
#else
#define mRelease(obj)   [obj release]; obj = nil;
#define mRetainProperty   @property (nonatomic, retain)
#endif

#endif



// View 坐标(x,y)和宽高(width,height)
#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y
#define WIDTH(v)                (v).frame.size.width
#define HEIGHT(v)               (v).frame.size.height

#define NavigationBarHeight 44.f
#define TabBarHeight 49.f
#define NavigationBarScreenHeight 108.f

#define StoryBoardDefined(a) [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:a]
#define LoadNibWithName(a)  [[[NSBundle mainBundle] loadNibNamed:a owner:self options:nil] objectAtIndex:0]

#define kscreenWidth [UIScreen mainScreen].bounds.size.width
#define kscreenHeight [UIScreen mainScreen].bounds.size.height

#define TelephoneWithNumber(view,a) \
  NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",a]];\
  UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];\
  [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];\
   [view addSubview:phoneCallWebView];\


// block self
#ifndef isNull
#define isNull(a)  ( (a==nil) || ((NSNull*)a==[NSNull null]) )
#define isNotNull(a)  (!isNull(a))
#endif


#define StringIsNull(string) (string == nil || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)

#define WEAKSELF typeof(self) __weak weakSelf = self;

#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;



#define KEdqCellHeight(x)     kscreenHeight > 568 ? ((x) / 600.0 * kscreenHeight) : x
#define SizeScale ((kscreenHeight > 568) ? kscreenHeight/580 : 1)

// 字体颜色
#define Gray136             RGBCOLOR(102, 102, 102)//一般正文

#define TextColorDeep       RGBCOLOR(51, 51, 51)//突出正文

#define TextColorTip        RGBCOLOR(153, 153, 153) //提示文字

#define LineColor  RGBCOLOR(222, 222, 222)//边框线条


// 背景灰
#define BackgroundColor     RGBCOLOR(241, 241, 241)

// 颜色(RGB)
#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]


//加载图片
#define mImageByName(name)        [UIImage imageNamed:name]
#define mImageByPath(name, ext)   [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:name ofType:ext]]



