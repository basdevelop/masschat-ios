//
//  CommonGameLogic.h
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonGameScene.h"

@interface CommonGameLogic : NSObject
@property(nonatomic, strong)CommonGameScene*            gameScene;

-(void)startGame;
-(void)initGame:(CommonGameScene*)parentScene;
-(void)quitGame;
@end
