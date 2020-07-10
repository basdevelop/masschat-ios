//
//  MessageBean.h
//  MassChat
//
//  Created by wsli on 2017/8/25.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MessageBeanType) {
        MessageBeanTypeChatMsg,
        MessageBeanTypeTransCtl,
        MessageBeanTypeAvatarReq,
        MessageBeanTypeAvatarResp
};

@interface MessageBean : NSObject<NSCoding>
@property(nonatomic) MessageBeanType    type;
@property(nonatomic) Boolean            inMsg;
@property(nonatomic, strong) NSString*  text;
@property(nonatomic, strong) NSDate*    time;
@property(nonatomic, strong) NSData*    binData;
@property(nonatomic) Boolean            status;


+(NSData*)generateData:(MessageBean*)obj;

+(MessageBean*)initWithData:(NSData*)data;

-(NSString*)toString;

@end
