//
//  GameViewController.h
//  MassChat
//
//  Created by wsli on 2017/9/11.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

typedef NS_ENUM(NSInteger, GameType) {
        GameTypeShaiZiFace = 0,
        GameTypeShaiZiStranger,
        GameTypeDouDiZhu,
        GameTypeMaJiang,
        GameTypeShengJi,
        GameTypeBaoHuang,
        GameTypeGouJi
};

@interface GameViewController : UIViewController<MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property(nonatomic)GameType            gameType;
@property(nonatomic)BOOL                isRoomOwner;
@property(nonatomic, strong) NSString*  roomOwnerPeerName;
@property(nonatomic, strong) MCSession* gameSession;
-(void)goBack;
@end
