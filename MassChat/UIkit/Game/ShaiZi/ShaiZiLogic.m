//
//  ShaiZiLogic.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ShaiZiLogic.h"
#import "WifiDirectManager.h"
#import "GameMessageBean.h"

@interface ShaiZiLogic(){
        ShaiZiGameStatus        _currentGameStatus;
        NSMutableArray*         _currentTablePosition;
}

@end

@implementation ShaiZiLogic
@synthesize diceRandomResultOfMe;

static ShaiZiLogic*     _instance = nil;

+(instancetype)getInstance{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                _instance = [[ShaiZiLogic alloc] init];
        });
        
        return _instance;
}

-(id)init{
        if (self = [super init]){
                _currentGameStatus = ShaiZiGameStatusInit;
                diceRandomResultOfMe = [[NSMutableArray alloc] initWithCapacity:DICE_NOMBER_PER_PLAYER];
        }
        return self;
}

-(void)quitGame{
        [super quitGame];
        _currentGameStatus = ShaiZiGameStatusInit;
        [diceRandomResultOfMe removeAllObjects];
}

-(void)initGame:(CommonGameScene *)parentScene{
        [super initGame:parentScene];
        [diceRandomResultOfMe removeAllObjects];
        _currentTablePosition = [NSMutableArray new];
        for (int i =  TablePositionMe; i < MAX_PLAYER_IN_THIS_GAME; i++){
                _currentTablePosition[i] = [NSNumber numberWithBool:YES];
        }
}
-(TablePosition)findEmptyTablePosition{
        TablePosition __block empty_position = TablePositionMe;
        [_currentTablePosition enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (YES == [(NSNumber*)obj boolValue]){
                        *stop = true;
                        empty_position = (TablePosition)idx;
                }
        }];
        
        return empty_position;
}

-(void)addPlayer:(PlayerShaiZi*)player{
        _currentTablePosition[player.tablePosition] = [NSNumber numberWithBool:NO];
}

-(void)removePlayer:(PlayerShaiZi*)player{
        _currentTablePosition[player.tablePosition] = [NSNumber numberWithBool:YES];
}

-(BOOL)canStartGame{
        return _currentGameStatus == ShaiZiGameStatusInit;
}

-(void)startGame{
        [super startGame];
        
        [diceRandomResultOfMe removeAllObjects];
        
        _currentGameStatus = ShaiZiGameStatusInGame;
        NSLog(@"------>>>我的色子结果<<<------");
        for (int i = 0; i < DICE_NOMBER_PER_PLAYER; i++){
                int result_dice = arc4random()%6 + 1;
                [diceRandomResultOfMe addObject:[NSNumber numberWithInt:result_dice]];
                NSLog(@"\t%d", result_dice);
        }
}

-(void)broadCastMyResult{
        if ( ShaiZiGameStatusInGame != _currentGameStatus){
                return ;
        }
        
        
        _currentGameStatus = ShaiZiGameStatusShowResult;
        
        MCSession* session = self.gameScene.parentCtroller.gameSession;
        
        NSLog(@"<<<---我要将我的结果广播给大家，当前链接个数:%lu", (unsigned long)[session.connectedPeers count]);
        
        GameMessageBean* msg_bean = [GameMessageBean new];
        
        msg_bean.type = GameMessageTypeShowResultResponse;
        msg_bean.data = [NSKeyedArchiver archivedDataWithRootObject:diceRandomResultOfMe];
        
        NSError* error = nil;
        [session  sendData:[GameMessageBean generateData:msg_bean]
                      toPeers:session.connectedPeers
                      withMode:(MCSessionSendDataReliable) error:&error];
        if (error){
                NSLog(@"发送游戏结果响应消息失败:%@", error.localizedDescription);
        }
}

-(void)setResult:(NSArray*)data ForPlayer:(TablePosition)tablePosition {
	[data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 NSLog(@"\t%d", [(NSNumber*)obj intValue]);
	}];
}

-(void)discoverResult{
	MCSession* session = self.gameScene.parentCtroller.gameSession;
        
	_currentGameStatus = ShaiZiGameStatusShowResult;
       
	GameMessageBean* msg_bean = [GameMessageBean new];
        
        NSLog(@"--->>>我开始发送请求结果的报文，当前链接个数:%lu", (unsigned long)[session.connectedPeers count]);
        
        msg_bean.type = GameMessageTypeShowResultRequest;
        msg_bean.data = [NSKeyedArchiver archivedDataWithRootObject:diceRandomResultOfMe];
        
        NSError* error = nil;
        [session  sendData:[GameMessageBean generateData:msg_bean]
                      toPeers:session.connectedPeers
                      withMode:(MCSessionSendDataReliable) error:&error];
        
        if (error){
                NSLog(@"发送游戏结果请求消息失败:%@", error.localizedDescription);
        }
}

-(void)notifyPlayerToStart{
        MCSession* session = self.gameScene.parentCtroller.gameSession;
        GameMessageBean* msg_bean = [GameMessageBean new];
        
        msg_bean.type = GameMessageTypeStartGame;
        msg_bean.data = nil;
        
        NSError* error = nil;
        [session  sendData:[GameMessageBean generateData:msg_bean]
                      toPeers:session.connectedPeers
                      withMode:(MCSessionSendDataReliable) error:&error];
        
        if (error){
                NSLog(@"发送游戏开始消息失败:%@", error.localizedDescription);
        }
}

@end
