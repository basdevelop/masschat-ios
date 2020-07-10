//
//  CommonGameLogic.m
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "CommonGameLogic.h"

@implementation CommonGameLogic

-(void)initGame:(CommonGameScene*)parentScene{
        _gameScene = parentScene;
}
-(void)quitGame{  
        self.gameScene = nil;
}

-(void)startGame{
}
@end
