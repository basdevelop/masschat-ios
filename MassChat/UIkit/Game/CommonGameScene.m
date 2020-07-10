//
//  CommonGameScene.m
//  MassChat
//
//  Created by wsli on 2017/9/14.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "CommonGameScene.h"

@implementation CommonGameScene

@synthesize parentCtroller, qrCodeImage;

-(void)startGame{
        [self cleanLastResult];
}

-(void)exitGame{
        [self.parentCtroller goBack];
}

-(void)updatePlayerInfo:(GamePlayerInfo*)playerInfo forPeerName:(NSString*)peerName{ 
}

-(void)removeUser:(MCPeerID *)peerID{
}

-(void) finishOneRound:(NSString*)peerName andShowResult:(NSData*)data{

}

-(void)gameResultData:(NSData*)data forPeer:(NSString*)peerName{
}

-(void)resetGame{
}

-(void)cleanLastResult{
}

-(BOOL)isGameRoomIsFull{
        return NO;
}

@end
