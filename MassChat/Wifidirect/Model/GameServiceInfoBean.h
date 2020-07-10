//
//  GameServiceInfoBean.h
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "GameViewController.h"

@interface GameServiceInfoBean : NSObject

@property(nonatomic, strong)    MCPeerID*       peerId;
@property(nonatomic)            GameType        gameType;
@property(nonatomic)            NSInteger       playerNo;
@property(nonatomic, strong)    NSString*       ownersName;

+(GameServiceInfoBean*) fromDic:(NSDictionary*)dic;
-(NSDictionary*)convertToDic;
@end
