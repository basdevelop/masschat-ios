//
//  ShaiZiLogic.h
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameLogic.h"
#import "GamePlayerInfo.h"
#import "PlayerShaiZi.h"

#define MAX_PLAYER_IN_THIS_GAME 4
#define DICE_NOMBER_PER_PLAYER  5

typedef NS_ENUM(NSInteger, ShaiZiGameStatus) {
        ShaiZiGameStatusInit = 0,
        ShaiZiGameStatusWaitOwner,
        ShaiZiGameStatusInGame,
        ShaiZiGameStatusShowResult
};

@interface ShaiZiLogic : CommonGameLogic

@property(nonatomic, strong) NSMutableArray* diceRandomResultOfMe;


+(instancetype)getInstance;

-(void)quitGame;

-(void)addPlayer:(PlayerShaiZi*)player;

-(void)removePlayer:(PlayerShaiZi*)player;

-(void)setResult:(NSArray*)data ForPlayer:(TablePosition)tablePosition;

-(void)discoverResult;
-(void)broadCastMyResult;
-(void)notifyPlayerToStart;
-(TablePosition)findEmptyTablePosition;
-(BOOL)canStartGame;
@end
