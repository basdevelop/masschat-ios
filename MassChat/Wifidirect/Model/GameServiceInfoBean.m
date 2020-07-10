//
//  GameServiceInfoBean.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "GameServiceInfoBean.h"

@implementation GameServiceInfoBean
@synthesize peerId, gameType, ownersName, playerNo;


+(GameServiceInfoBean*) fromDic:(NSDictionary*)dic{
        
        GameServiceInfoBean* bean = [GameServiceInfoBean new];
        [bean setGameType:[[dic objectForKey:@"gameType"] integerValue]];
        [bean setOwnersName:[dic objectForKey:@"ownersName"]];
        [bean setPlayerNo:[[dic objectForKey:@"playerNo"] integerValue]];
        
        return bean;
}


-(NSDictionary*)convertToDic{
        return @{@"ownersName":ownersName == nil?@"":ownersName,
                 @"gameType": [NSString stringWithFormat:@"%ld", (long)gameType],
                 @"playerNo": [NSString stringWithFormat:@"%ld", (long)playerNo]
                 };
}

@end
