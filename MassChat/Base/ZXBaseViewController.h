//
//  ZXBaseViewController.h
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, EDQShowMode) {
        EDQPush = 0,
        EDQPresent
};
@interface ZXBaseViewController : UIViewController
@property(nonatomic,assign) EDQShowMode showMode;
@property(nonatomic,assign) BOOL hiddenBackBtn;//NO
- (void)clickBack:(id)sender;
@end
