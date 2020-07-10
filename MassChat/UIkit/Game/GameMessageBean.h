//
//  GameMessageBean.h
//  MassChat
//
//  Created by wsli on 2017/9/14.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GameMessageType) {
        GameMessageTypeBroadCast,
        GameMessageTypeStartGame,
        GameMessageTypeShowResultRequest,
        GameMessageTypeShowResultResponse
};

@interface GameMessageBean : NSObject<NSCoding>
@property(nonatomic)GameMessageType     type;
@property(nonatomic, strong)NSData*     data;

+(NSData*)generateData:(GameMessageBean*)obj;

+(GameMessageBean*)initWithData:(NSData*)data;

@end
