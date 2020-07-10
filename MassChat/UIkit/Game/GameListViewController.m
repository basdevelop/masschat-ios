//
//  GameListViewController.m
//  MassChat
//
//  Created by wsli on 2017/9/12.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "GameListViewController.h"
#import "DropDownMenu.h"
#import "GameViewController.h"
#import "WifiDirectManager.h"
#import "GameServiceInfoBean.h"
#import "JoinGameTableViewCell.h"
#import "GameServerTableViewCell.h"
#import "ZXUser.h"

@interface GameListViewController ()<MCNearbyServiceBrowserDelegate>{
        DropDownMenu *  _dropDownMenu;
        NSMutableDictionary     *_gameServiceAvailable;
}
@end

@implementation GameListViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        _gameServiceAvailable = [NSMutableDictionary new];
        
        self.title = @"游戏";         
        
        self.hiddenBackBtn = YES;
        self.tableView.height = self.tableView.height - TabBarHeight;
        self.tableView.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.tableView registerNib:[UINib nibWithNibName:@"JoinGameTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"JoinGameTableViewCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"GameServerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GameServerTableViewCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [[WifiDirectManager getInstance] createGameServersBrowser:self];
}


-(void)joinTheGame:(GameServiceInfoBean*)gameRoomInfo{
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameViewController *game_vc = [storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
        game_vc.hidesBottomBarWhenPushed = YES;
        game_vc.gameType = gameRoomInfo.gameType;
        
        MCSession* session = [[WifiDirectManager getInstance] enterThisGameRoom: gameRoomInfo.peerId delegate:game_vc];
        [game_vc setGameSession:session];
        [game_vc setIsRoomOwner:NO];
        [game_vc setRoomOwnerPeerName:gameRoomInfo.peerId.displayName];
        
        [self.navigationController pushViewController:game_vc animated:YES];
}

- (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (section == 0) {
                return 1;
        }
        
        return [_gameServiceAvailable count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section  == 0) {
                return 142.5f;
        }
        return KEdqCellHeight(150);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
                static NSString *identify = @"JoinGameTableViewCell";
                JoinGameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                cell.parentController = self;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
        }
        
        static NSString *identify = @"GameServerTableViewCell";
        GameServerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSArray* server_list = _gameServiceAvailable.allValues;
        GameServiceInfoBean* service_bean = [server_list objectAtIndex:indexPath.row];
        
        [cell renderContent:service_bean];
        [cell setParentController:self];
        
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - 刷新、加载
-(void)loadNewData
{dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];});
}

-(void)loadMoreData{dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_footer endRefreshing];});
}


#pragma mark - 设备状体变更
- (void)friendStateChanges{
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
        });
}


#pragma mark - 发现游戏服务的代理方法 
- (void)browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(NSDictionary<NSString *, NSString *> *)info{
        
        if (nil == info){
                [_gameServiceAvailable removeObjectForKey:peerID.displayName];
                [self friendStateChanges];
                return;
        }
        
        GameServiceInfoBean* service_bean = [GameServiceInfoBean fromDic:info];
        
        NSLog(@"---发现:%@--链接个数:%ld--", peerID.displayName, (long)service_bean.playerNo);
        
        [service_bean setPeerId:peerID];
        
        [_gameServiceAvailable setObject:service_bean forKey:peerID.displayName];
        [self friendStateChanges];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
        [_gameServiceAvailable removeObjectForKey:peerID.displayName];
        [self friendStateChanges];
        NSLog(@"---下线了:%@----", peerID.displayName);
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
        NSLog(@"---发现游戏失败:%@---", [error localizedDescription]); dispatch_async(dispatch_get_main_queue(), ^{
        [[JCCUtils sharedInstance] showProgressHud:self.view withMessage:@"创建游戏室失败，请检查是否开启wifi"];
                });
}


#pragma mark - 扫码进入游戏
- (void)getQRStringSuccess:(NSString*) QRString{
        GameServiceInfoBean *game_room_info = [_gameServiceAvailable objectForKey:QRString];
        
        if (nil == game_room_info){ dispatch_async(dispatch_get_main_queue(), ^{
                [[JCCUtils sharedInstance] showProgressHud:self.view withMessage:@"游戏房间已经不存在"];
                });
                return;
        }
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GameViewController *game_vc = [storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
        game_vc.hidesBottomBarWhenPushed = YES;
        game_vc.gameType = game_room_info.gameType;
        
        MCSession* session = [[WifiDirectManager getInstance] enterThisGameRoom: game_room_info.peerId delegate:game_vc];
        [game_vc setGameSession:session];
        [game_vc setIsRoomOwner:NO];
        [game_vc setRoomOwnerPeerName:game_room_info.peerId.displayName];
        
        [self.navigationController pushViewController:game_vc animated:YES];
}
- (void)getQRStringFailed{ dispatch_async(dispatch_get_main_queue(), ^{
        [[JCCUtils sharedInstance] showProgressHud:self.view withMessage:@"扫码失败"];});
}
@end
