//
//  CommonPlayer.h
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "CommonGameScene.h"
#import "GamePlayerInfo.h"

@interface CommonPlayer : NSObject

@property(nonatomic, strong)SKSpriteNode*       playerNode;
@property(nonatomic, strong)SKNode*             emptyNode;
@property(nonatomic, strong)SKLabelNode*        nickNameNode;
@property(nonatomic, strong)SKSpriteNode*       avatarImageNode; 
@property(nonatomic)BOOL                        isRoomOwner;
@property(nonatomic, strong)CommonGameScene*    gameScene;

-init:  (CommonGameScene*)scene
        withNodeName:(NSString*)nodeName
        avatarImageData:(NSData*)avatarImgData
        nickName:(NSString*)nickName;

-init:  (CommonGameScene*)scene
        withNodeName:(NSString*)nodeName
        avatarImage:(UIImage*)avatarImg
        nickName:(NSString*)nickName;

+(void)copy:(GamePlayerInfo*)playerInfo from:(id)source to:(id)target withPlaceHolder:(SKNode*)placeHolder;

-(UIImage*)getScaledImage:(NSData*) imageData;

-(UIImage*)getScalcedImage:(UIImage*)originalImage;

@end
