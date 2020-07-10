//
//  ZXFriendViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXFriendViewController.h"
#import "ZXChatViewController.h"
#import "ZXSeachCell.h"
#import "ZXChatCell.h"
#import "DropDownMenu.h"
#import "DataBaseManager.h"
#import "ZXHistoryMessageViewController.h"

@interface ZXFriendViewController ()<WifiDirectPeerDelegate>
{
        DropDownMenu *_dropDownMenu;
        NSArray *_titles;
}

@property (nonatomic, strong) NSMutableDictionary*      stillOnlineFriends;
@property (nonatomic, strong) NSMutableDictionary*      hasOfflineFriends;

@end

@implementation ZXFriendViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        self.navigationItem.title = @"周围";
        self.hiddenBackBtn = YES;
        self.tableView.height = self.tableView.height - TabBarHeight;
        self.tableView.backgroundColor = RGBCOLOR(245, 245, 245);
        
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXSeachCell" bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:@"SeachCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXChatCell" bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:@"ChatCell"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [[WifiDirectManager getInstance] startShowMyself];
        
        [[WifiDirectManager getInstance] findNearByFriends];
}

-(void)viewDidAppear:(BOOL)animated{
        [super viewDidAppear:animated];
        [[WifiDirectManager getInstance] setPeerDelegate:self];
        [self reloadTableData];
}

-(void)viewDidDisappear:(BOOL)animated{
        [super viewDidDisappear:animated];
        [[WifiDirectManager getInstance] setPeerDelegate:nil];

}
-(void)reloadTableData{
        self.stillOnlineFriends = [[WifiDirectManager getInstance] getPeerDeviceDic];
        
        self.hasOfflineFriends  = [[DataBaseManager getInstance] loadFriendsHasChatHistory];
        
        [self.stillOnlineFriends enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
                FriendNearBy *friend_bean = [self.hasOfflineFriends objectForKey:key];
                if (nil != friend_bean){
                        [self.hasOfflineFriends removeObjectForKey:key];
                         [(FriendNearBy *)obj setLastMessage:friend_bean.lastMessage];
                }
        }];
        
        [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 2){
                return YES;
        }
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section != 2){
                return;
        }
        ZXChatCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.hasOfflineFriends removeObjectForKey:cell.peerName];
        
        [[DataBaseManager getInstance] removeFriendByPeerName:cell.peerName];
        
        // 刷新
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

/**
 *  修改Delete按钮文字为“删除”
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
        return @"删除";
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
        if (section  == 1){
                if (self.stillOnlineFriends.count > 0)
                        return @"在线";
                else
                        return nil;
                
        }else if (section  == 2){
                if (self.hasOfflineFriends.count > 0)
                        return @"离线";
                else
                        return nil;
        }else {
                return nil;
        }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (section == 0) {
                return 1;
        }else if (section == 1){
                return self.stillOnlineFriends.count;
        }else {
                return self.hasOfflineFriends.count;
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section  == 0) { 
                return 50.f;
        }
        
        return KEdqCellHeight(70);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
                static NSString *identify = @"SeachCell";
                ZXSeachCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
        }
        
        static NSString *identify = @"ChatCell";
        ZXChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (indexPath.section == 1){
                
                FriendNearBy* friend_bean = [self.stillOnlineFriends.allValues objectAtIndex:indexPath.row];
                
                [cell renderContent:friend_bean withOnlineStatus:YES];
        }else if (indexPath.section == 2){
                FriendNearBy* friend_bean = [self.hasOfflineFriends.allValues objectAtIndex:indexPath.row];
                
                [cell renderContent:friend_bean withOnlineStatus:NO];
        }
        return cell;
        
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
        if (indexPath.section == 0) {
                return;
        }else if (indexPath.section == 1) {
                
                FriendNearBy* friend_bean = [self.stillOnlineFriends.allValues objectAtIndex:indexPath.row];
                
                ZXChatViewController *chatVC = [[ZXChatViewController alloc]
                                                initWithFriend:friend_bean];
                chatVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatVC animated:YES];
                
        }else if (indexPath.section == 2){
                
                NSString* peer_name = [self.hasOfflineFriends.allKeys objectAtIndex:indexPath.row];
                FriendNearBy* friend_bean = [self.hasOfflineFriends objectForKey:peer_name];
                
                ZXHistoryMessageViewController *historyVc = [[ZXHistoryMessageViewController alloc]
                                                             initWithPeerName:peer_name andFriendName:friend_bean.name];

                historyVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:historyVc animated:YES];
        }
}

#pragma mark - 刷新、加载
-(void)loadNewData{
        [self.tableView.mj_header endRefreshing];
}

-(void)loadMoreData{
        [self.tableView.mj_footer endRefreshing];
}

#pragma mark - peer 对象状态发生变化
- (void)friendStateChanges{
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableData];
        });
}

@end
