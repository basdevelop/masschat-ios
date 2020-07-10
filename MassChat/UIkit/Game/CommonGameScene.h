//
//  CommonGameScene.h
//  MassChat
//
//  Created by wsli on 2017/9/14.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GamePlayerInfo.h"
#import "GameViewController.h" 

@class CommonPlayer;

@interface CommonGameScene : SKScene
@property(nonatomic, weak)GameViewController*           parentCtroller; 
@property(nonatomic, strong)NSMutableDictionary*        playersInGame;
@property(nonatomic, strong)UIImage*                    qrCodeImage;

-(void)startGame;

-(void)exitGame;

-(void)updatePlayerInfo:(GamePlayerInfo*)playerInfo forPeerName:(NSString*)peerName;

-(void)removeUser:(MCPeerID *)peerID;

-(void) finishOneRound:(NSString*)peerName andShowResult:(NSData*)data;

-(void)gameResultData:(NSData*)data forPeer:(NSString*)peerName;

-(void)resetGame;

-(void)cleanLastResult;

-(BOOL)isGameRoomIsFull;

@end
