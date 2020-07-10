//
//  DialogScene.m
//  MassChat
//
//  Created by wsli on 2017/9/22.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "DialogScene.h"
@interface DialogScene(){
        SKLabelNode*    _tittleNode;
        SKLabelNode*    _contentNode;
        SKSpriteNode*   _okButtonNode;
}
@end
@implementation DialogScene
@synthesize parentCtroller;

- (void)sceneDidLoad{
        _tittleNode = (SKLabelNode*)[self childNodeWithName:@"Dialog_Title"];
        _contentNode = (SKLabelNode*)[self childNodeWithName:@"Dialog_Content"];
        _okButtonNode = (SKSpriteNode*)[self childNodeWithName:@"Dialog_Confirm"];
        NSLog(@"---2修改之前:%@-%@", _tittleNode.text, _contentNode.text);
}

-(void)renderTitle:(NSString*)tittle andContent:(NSString*)content{
        NSLog(@"---1修改之前:%@-%@", _tittleNode.text, _contentNode.text);
        _tittleNode.text = tittle;
        _contentNode.text = content;
        _contentNode.position = CGPointMake(0.f, 0.f); 
        NSLog(@"修改之后:%@-%@", _tittleNode.text, _contentNode.text);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        NSLog(@"----选中的名字:%@---", node.name);
        if ([node isEqualToNode:_okButtonNode] || (node.parent &&
           [node.parent isEqualToNode:_okButtonNode])){
                [self.parentCtroller goBack];
        }
}
@end
