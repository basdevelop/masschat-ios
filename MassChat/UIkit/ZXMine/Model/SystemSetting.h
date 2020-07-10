//
//  SystemSetting.h
//  MassChat
//
//  Created by wsli on 2017/9/9.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemSetting : NSObject<NSCoding>
+ (id)getInstance;
-(void)sync;

@property(nonatomic) BOOL       soundsSwitch;
@property(nonatomic) BOOL       businessInfoSwitch;
@end
