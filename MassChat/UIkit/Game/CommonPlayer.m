//
//  CommonPlayer.m
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "CommonPlayer.h"

#define AVATAR_IMG_PLACE_HOLDER         @"AVATAR_IMG_PLACE_HOLDER"
#define DEFAULT_AVATAR_IMAGE_NAME       @"default_game_avatar"
#define PLAYER_NICK_NAME_NODE_NAME      @"PLAYER_NICK_NAME_NODE_NAME"

@implementation CommonPlayer


-init:(CommonGameScene*)scene withNodeName:(NSString*)nodeName
        avatarImageData:(NSData*)avatarImgData nickName:(NSString*)nickName{
        
        self = [super init];
        
        _gameScene = scene;
        
        _playerNode = (SKSpriteNode*)[_gameScene childNodeWithName:nodeName];         
        
        UIImage* image = [self getScaledImage:avatarImgData];;
        
        return [self initwithAvatarImage:image nickName:nickName];
}

-init:(CommonGameScene*)scene
        withNodeName:(NSString*)nodeName
        avatarImage:(UIImage*)avatarImg
        nickName:(NSString*)nickName{
        
        self = [super init];
        
        _gameScene = scene;
        
        _playerNode = (SKSpriteNode*)[_gameScene childNodeWithName:nodeName];
        
        UIImage* image = [self getScalcedImage:avatarImg];
                
        [self initwithAvatarImage:image nickName:nickName]; 
        
        return self;
}

-initwithAvatarImage:(UIImage*)avatarImg
        nickName:(NSString*)nickName{
        
        SKTexture* avatar_texture = [SKTexture textureWithImage:avatarImg];
        
        SKNode* empty_node = [_playerNode childNodeWithName:AVATAR_IMG_PLACE_HOLDER];
        _avatarImageNode = [SKSpriteNode spriteNodeWithTexture:avatar_texture];
        
        _avatarImageNode.position = empty_node.position;
        [empty_node removeFromParent];
        
        [_playerNode addChild:_avatarImageNode];
        
        _nickNameNode = (SKLabelNode*)[_playerNode childNodeWithName:PLAYER_NICK_NAME_NODE_NAME];
        [_nickNameNode setText:nickName];
        
        return self;
}

+(void)copy:(GamePlayerInfo*)playerInfo from:(id)source to:(id)target withPlaceHolder:(SKNode*)placeHolder {
        
        CommonPlayer* target_obj = (CommonPlayer*)target;
        CommonPlayer* source_obj = (CommonPlayer*)source;
        
        target_obj.gameScene = source_obj.gameScene;
        target_obj.playerNode = [[SKSpriteNode alloc] initWithTexture:source_obj.playerNode.texture];
        
        target_obj.playerNode.position = placeHolder.position;
        target_obj.playerNode.zPosition = placeHolder.zPosition;
        
        SKLabelNode* palyer_nickname = [source_obj.nickNameNode copy];
        [target_obj.playerNode addChild:palyer_nickname];
        
        palyer_nickname.position = source_obj.nickNameNode.position;
        palyer_nickname.text = playerInfo.nickName;
        target_obj.nickNameNode = palyer_nickname;
        
        UIImage* image = [source_obj getScaledImage:playerInfo.imageData];
        
        SKTexture* avatar_texture = [SKTexture textureWithImage:image];
        SKSpriteNode* player_avatar = [SKSpriteNode spriteNodeWithTexture:avatar_texture];
        
        [target_obj.playerNode addChild:player_avatar];
        player_avatar.position = source_obj.avatarImageNode.position;
        target_obj.avatarImageNode = player_avatar;
        
        target_obj.isRoomOwner = playerInfo.isRoomOwner; 
}

-(UIImage*)getScaledImage:(NSData*) imageData{
        
        UIImage* image = nil;
        
        if (nil != imageData){
                
                CGSize node_size = [_playerNode size];
                
                UIImage* original_img = [[UIImage alloc] initWithData:imageData];
                
                float scale =  original_img.size.width / (0.8f * node_size.width);
                
                image = [UIImage imageWithData:imageData scale:scale];
        }else{
                
                CGSize node_size = [_playerNode size];
                
                UIImage* original_img = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE_NAME];;
                
                float scale =  original_img.size.width / (0.8f * node_size.width);
                
                NSData* image_data = UIImagePNGRepresentation(original_img);
                
                image = [UIImage imageWithData:image_data scale:scale];
        }
        
        return image;
}

-(UIImage*)getScalcedImage:(UIImage*)originalImage{
        
        UIImage* image = nil;
        if (nil == originalImage){
                originalImage = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE_NAME];
         }
        
        CGSize node_size = [_playerNode size];
        
        float scale = originalImage.size.width / (0.8f * node_size.width);
        
        NSData* image_data = UIImagePNGRepresentation(originalImage);
        
        image = [UIImage imageWithData:image_data scale:scale];
         
        return image;
}

@end
