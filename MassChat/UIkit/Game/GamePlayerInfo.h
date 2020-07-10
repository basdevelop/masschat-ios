//
//  GamePlayerInfo.h
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GamePlayerInfo : NSObject<NSCoding>
@property(nonatomic, strong)NSString*   nickName;
@property(nonatomic)NSInteger           coinsNo;
@property(nonatomic)BOOL                isRoomOwner;
@property(nonatomic, strong)NSData*     imageData;

+(NSData*)generateData:(GamePlayerInfo*)obj;

+(GamePlayerInfo*)loadSelfInfo;

+(GamePlayerInfo*)initWithData:(NSData*)data;

@end
