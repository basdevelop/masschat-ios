//
//  JoinGameTableViewCell.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "JoinGameTableViewCell.h"
#import "SGQRCodeScanningVC.h"
#import "WifiDirectManager.h"
#import "ZXUser.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation JoinGameTableViewCell
@synthesize parentController;

- (void)awakeFromNib {
    [super awakeFromNib];
        ZXUser* current_user = [ZXUser loadSelfProfile];
        _userNickName.text = current_user.name == nil ? current_user.nickName:current_user.name;
        _userSignature.text = current_user.signature;
        _userAvatar.image = current_user.avatar == nil ?[UIImage imageNamed:@"default_game_avatar"]:current_user.avatar;
        [[JCCUtils sharedInstance] graphicsImage:_userAvatar];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)scanCodeToJoinGame:(id)sender {
        if (![[JCCUtils sharedInstance] checkCameraAutherization:self.parentController]){
                return ;
        }
        
        SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.delegate = self.parentController;
        [self.parentController.navigationController pushViewController:vc animated:YES];
}

-(void)createGameByType:(GameType)gameType{
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameViewController *game_vc = [storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
        game_vc.hidesBottomBarWhenPushed = YES;
        game_vc.gameType = gameType;
        
        GameServiceInfoBean* service_bean = [GameServiceInfoBean new];
        service_bean.playerNo = 1;
        
        ZXUser* current_user = [ZXUser loadSelfProfile];
        service_bean.ownersName = current_user.name == nil ? current_user.nickName:current_user.name;
        service_bean.gameType = gameType;
        
        MCSession* session = [[WifiDirectManager getInstance] createGameRoom:service_bean
                                                       withAdvertiseDelegate:game_vc
                                                          andSessionDelegate:game_vc];
        [game_vc setGameSession:session];
        [game_vc setIsRoomOwner:YES];
        [game_vc setRoomOwnerPeerName:[[WifiDirectManager getInstance] gamePeerID].displayName];
        
        [self.parentController.navigationController pushViewController:game_vc animated:YES];
}

- (IBAction)createNewGameRoom:(UIButton *)sender {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请选择您要创建的游戏"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancel_action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                              handler:nil];
        [alert addAction:cancel_action];
        
        UIAlertAction* create_action = [UIAlertAction actionWithTitle:@"大话骰(面对面)" style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) { [self createGameByType:GameTypeShaiZiFace];}];
        [alert addAction:create_action];
        
        
        //TODO::需要陆续完善游戏内容
//        create_action = [UIAlertAction actionWithTitle:@"大话骰(陌生人-开发中)" style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action) {  [self createGameByType:GameTypeShaiZiStranger]; }];
//        [alert addAction:create_action];
//        create_action = [UIAlertAction actionWithTitle:@"斗地主(开发中)" style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {  [self createGameByType:GameTypeDouDiZhu]; }];
//        [alert addAction:create_action];
        
        [self.parentController presentViewController:alert animated:YES completion:nil];
}

@end
