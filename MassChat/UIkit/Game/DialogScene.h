//
//  DialogScene.h
//  MassChat
//
//  Created by wsli on 2017/9/22.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"

@interface DialogScene : SKScene
@property(nonatomic, weak)GameViewController*           parentCtroller;

-(void)renderTitle:(NSString*)tittle andContent:(NSString*)content;
@end
