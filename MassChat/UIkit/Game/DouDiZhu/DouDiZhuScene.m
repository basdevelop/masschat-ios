//
//  DouDiZhuScene.m
//  MassChat
//
//  Created by wsli on 2017/9/11.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "DouDiZhuScene.h"
#import "DouDiZhuLogic.h"

@implementation DouDiZhuScene
@synthesize returnBackBtn, parentCtroller;

- (void)sceneDidLoad{
        returnBackBtn = (SKSpriteNode*)[self childNodeWithName:@"icon_returnback"];
        
        [[DouDiZhuLogic getInstance] shuffle];
}

-(void)exitGame{
        [super exitGame];
        [[DouDiZhuLogic getInstance] quitGame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if ([node.name isEqualToString:@"icon_returnback"]) {
                [self exitGame];
        }
}

@end
