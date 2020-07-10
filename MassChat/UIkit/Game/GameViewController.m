//
//  GameViewController.m
//  MassChat
//
//  Created by wsli on 2017/9/11.
//  Copyright © 2017年 众讯. All rights reserved.
//

#import "GameViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "DouDiZhuScene.h"
#import "AppDelegate.h"
#import "WifiDirectManager.h"
#import "ShaiZiScene.h"
#import "GamePlayerInfo.h"
#import "GameMessageBean.h"
#import "CommonGameScene.h"
#import "DialogScene.h"
#import "SGQRCodeGenerateManager.h"

@interface GameViewController(){
        CommonGameScene* _currentGameScene;
}

@end

@implementation GameViewController
@synthesize gameType, gameSession, isRoomOwner, roomOwnerPeerName;

- (void)viewDidLoad {
        [super viewDidLoad];
        self.navigationController.navigationBarHidden = YES;
        
        SKView* view = (SKView*)self.view;
        switch (gameType) {
                case GameTypeShaiZiFace:
                        _currentGameScene = [self loadSceneOfShaiZi:view];
                        break;
                case GameTypeShaiZiStranger:
                        _currentGameScene = [self loadSceneOfShaiZi:view];
                        break;
                case GameTypeDouDiZhu:
                        _currentGameScene = [self loadSceneOfDouDiZhu:view];
                        break;
                default:
                        break;
        }
        
        _currentGameScene.qrCodeImage = [SGQRCodeGenerateManager
                                         SG_generateWithDefaultQRCodeData:roomOwnerPeerName
                                         imageViewWidth:80];
        _currentGameScene.scaleMode = SKSceneScaleModeAspectFit;
        [view presentScene:_currentGameScene];
        view.ignoresSiblingOrder = YES;
        view.showsFPS = YES;
        view.showsNodeCount = YES;
}

-(CommonGameScene*)loadSceneOfShaiZi:(SKView*)view{
        ShaiZiScene* game_scene = [ShaiZiScene nodeWithFileNamed:@"ShaiZi"];
        game_scene.parentCtroller = self;
        game_scene.gameType = gameType;
        return game_scene;
}

-(CommonGameScene*)loadSceneOfDouDiZhu:(SKView*)view{
        DouDiZhuScene* game_scene = [DouDiZhuScene nodeWithFileNamed:@"DouDiZhu"];
        game_scene.parentCtroller = self;
        return game_scene;
}

-(void)dealloc{
        NSLog(@"finished.");
}

-(void)viewWillAppear:(BOOL)animated{
        [super viewWillAppear:animated];

        [(AppDelegate *)[UIApplication sharedApplication].delegate setOrientationMask: UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight];
        
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
}

-(void)viewWillDisappear:(BOOL)animated{
        [super viewWillDisappear:animated];
        [(AppDelegate *)[UIApplication sharedApplication].delegate setOrientationMask:UIInterfaceOrientationMaskPortrait];
        
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationMaskPortrait) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
        self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
}

-(void)goBack{
        
        [[WifiDirectManager getInstance] leaveTheGameRoom];
        
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 创建游戏服务器的回调函数
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
        didReceiveInvitationFromPeer:(MCPeerID *)peerID
        withContext:(nullable NSData *)context
        invitationHandler:(void (^)(BOOL accept, MCSession * session))invitationHandler{
        
        if (nil != _currentGameScene && [_currentGameScene isGameRoomIsFull]){
//                [self notifyPlayerThatRoomIsFull:peerID];
                invitationHandler(NO, gameSession);
        }else{
                invitationHandler(YES, gameSession);
        }
}


//TODO::创建失败的时候，在游戏提示服务失败，退出游戏。
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
        NSLog(@"创建游戏服务器失败.");
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示框"message:@"创建游戏失败，请检查wifi是否开启" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_Nonnullaction) {
                [self goBack];
        }]];

        dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
        });
} 

#pragma mark - 游戏玩家建立链接的回调函数
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
        
        switch (state) {
                case MCSessionStateConnecting:
                        NSLog(@"-----peer-%@-is MCSessionStateConnecting-----", peerID.displayName);
                        break;
                case MCSessionStateConnected:{
                        NSLog(@"-----peer-%@-is MCSessionStateConnected-----", peerID.displayName);
                        [self broadCastMyInfoToPeer:peerID];
                } break;
                case MCSessionStateNotConnected:{
                        NSLog(@"-----peer-%@-is MCSessionStateNotConnected-----", peerID.displayName);
                        [self removeUser:peerID];
                }break;
                default:
                        break;
        }
}

- (void)session:(MCSession *)session
        didReceiveData:(NSData *)data
        fromPeer:(MCPeerID *)peerID{
    
        GameMessageBean* msg_bean = [GameMessageBean initWithData:data];
        switch (msg_bean.type) {
                case GameMessageTypeBroadCast:{
                        GamePlayerInfo* player_info = [GamePlayerInfo initWithData:msg_bean.data];
                        [_currentGameScene updatePlayerInfo:player_info forPeerName:peerID.displayName];
                }break;
                case GameMessageTypeStartGame:{
                        [_currentGameScene startGame];
                }break;
                
                case GameMessageTypeShowResultRequest:{
                        [_currentGameScene finishOneRound:peerID.displayName andShowResult:msg_bean.data];
                }break;
                default:
                case GameMessageTypeShowResultResponse:{
                        NSLog(@"--->>>收到了来自:%@ 的响应报文,这个是response响应的数据<<<---", peerID.displayName);
                        [_currentGameScene gameResultData:msg_bean.data forPeer:peerID.displayName];
                }break;
        }
}

#pragma mark - 函数没用

- (void) session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
        
}

- (void) session:(MCSession *)session
        didStartReceivingResourceWithName:(NSString *)resourceName
        fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
        
}

- (void) session:(MCSession *)session
        didFinishReceivingResourceWithName:(NSString *)resourceName
                            fromPeer:(MCPeerID *)peerID
                            atURL:(NSURL *)localURL withError:(nullable NSError *)error{
}

-(void)updateCurrentGameUserNo{
        if (isRoomOwner){
                [[WifiDirectManager getInstance] changeCurrentGamePlayerNo:gameType];
        }
}

#pragma mark - 游戏的工作
-(void)broadCastMyInfoToPeer:(MCPeerID*)peerID{ 
        
        GamePlayerInfo* palyer_data = [GamePlayerInfo loadSelfInfo];
        [palyer_data setIsRoomOwner:isRoomOwner]; 
        
        GameMessageBean* msg_bean = [GameMessageBean new];
        msg_bean.type = GameMessageTypeBroadCast;
        msg_bean.data = [GamePlayerInfo generateData:palyer_data];
        
        NSError* error = nil;
        [gameSession sendData:[GameMessageBean generateData:msg_bean] toPeers:@[peerID]
                     withMode:(MCSessionSendDataReliable) error:&error];
        
        if (error){
                //TODO:: 游戏通讯中断.
                NSLog(@"刚刚连接时，发送自己的个人游戏信息失败:%@", error.localizedDescription);
        }
        
        [self updateCurrentGameUserNo];
}


-(void)removeUser:(MCPeerID *)peerID{
        [_currentGameScene removeUser:peerID];
        [self updateCurrentGameUserNo];
        
        if ([peerID.displayName isEqualToString:roomOwnerPeerName]){
                DialogScene* dialog_scene = [DialogScene nodeWithFileNamed:@"Dialogs.sks"];
                dialog_scene.scaleMode = SKSceneScaleModeAspectFit;
                dialog_scene.parentCtroller = self;
                [dialog_scene renderTitle:@"提示" andContent:@"房间已满或者房主已经退出!"];
                [(SKView*)self.view presentScene:dialog_scene];
        }
}

@end
