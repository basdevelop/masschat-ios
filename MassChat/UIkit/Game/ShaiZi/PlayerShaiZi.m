//
//  PlayerShaiZi.m
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "PlayerShaiZi.h"
#define ROOM_OWNER_FLAG                 @"ROOM_OWNER_FLAG"

@implementation PlayerShaiZi
@synthesize tablePosition;

+(id)copy:(GamePlayerInfo*)playerInfo from:(PlayerShaiZi*)source withPlaceHolder:(SKNode*)placeHolder{
        PlayerShaiZi* target = [PlayerShaiZi new];
        [CommonPlayer copy:playerInfo from:source to:target withPlaceHolder:placeHolder];
        
        if (playerInfo.isRoomOwner){
                SKSpriteNode* room_flag = (SKSpriteNode*)[source.playerNode childNodeWithName:ROOM_OWNER_FLAG];
                
                CGPoint position =  room_flag.position;
                [room_flag moveToParent:target.playerNode];
                [room_flag setPosition:position];
        }
        
        return target;
}

@end
