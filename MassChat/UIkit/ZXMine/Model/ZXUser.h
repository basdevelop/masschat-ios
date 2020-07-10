//
//  ZXUser.h
//  ZX
//
//  Created by 许李超 on 17/7/23.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "JRFBaseObject.h"
#import "WXApi.h"

@interface ZXUser : NSObject<NSCoding>
@property (copy, nonatomic) NSString*   nickName;
@property (copy, nonatomic) NSString*   wechatId;
@property (copy, nonatomic) NSString*   signature;
@property (copy, nonatomic) NSString*   name;
@property (copy, nonatomic) NSString*   phone;
@property(nonatomic, copy)  NSString*   gender;
@property(nonatomic, copy)  NSString*   title;
@property(nonatomic, copy)  NSString*   company;
@property(nonatomic, copy)  NSString*   address;
@property(nonatomic, copy)  UIImage*    avatar;

+(instancetype)loadSelfProfile;

+(void)initSelfByWixinInfo:(SendAuthResp*)resp;

+(void)syncDataToSavePath:(ZXUser*)userData;

@end
