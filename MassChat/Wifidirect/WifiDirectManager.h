//
//  WifiDirectManager.h
//  MassChat
//
//  Created by wsli on 2017/8/22.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "FriendNearBy.h"
#import "MessageBean.h"
#import "GameServiceInfoBean.h"
#import "GameViewController.h"

@protocol WifiDirectPeerDelegate <NSObject>
- (void)friendStateChanges;
@end

@protocol WifiDirectSessionDelegate <NSObject>
- (void)didConnectedBySession:(MCSession*)session;
- (void)hasDisConnectedBySession;
@end

@protocol WifiDirectGameServerDelegate <NSObject>


@end

@interface WifiDirectManager : NSObject

@property(nonatomic, strong) MCPeerID*                          mcPeerID;

@property(nonatomic, strong) MCNearbyServiceBrowser*            serviceBrowser;

@property(nonatomic, strong) MCNearbyServiceAdvertiser*         serviceAdvertiser;

@property(nonatomic, strong) id<WifiDirectPeerDelegate>         peerDelegate;

@property(nonatomic, strong) id<WifiDirectSessionDelegate>      sessionDelegate;



@property(nonatomic, strong) MCPeerID*                          gamePeerID;

@property(nonatomic, strong) MCNearbyServiceBrowser*            gameServerBrowser;

@property(nonatomic, strong) MCNearbyServiceAdvertiser*         gameServierAdvertiser;




+(id)getInstance;

-(void)startShowMyself;

-(void)restartShowMySelf;

-(void)findNearByFriends;

-(void)inviteThisFriend:(MCPeerID*)peerId;

-(NSArray*)getPeerDeviceList;

-(NSMutableDictionary*)getPeerDeviceDic;

-(FriendNearBy*)getFriendByPeerId:(MCPeerID*)peerId;

-(BOOL)sendMessage:(MessageBean*)msg withPeerName:(NSString*) peerName;

-(BOOL) connectPeer:peer_name forTransport:path;


#pragma mark - 文件传输函数
-(MCSession*)getCachedSession:(NSString*)peerName;


#pragma mark - 游戏的函数
-(void)createGameServersBrowser:(id<MCNearbyServiceBrowserDelegate>)delegate;

-(MCSession*)   createGameRoom:(GameServiceInfoBean*)gameBean
                withAdvertiseDelegate:(id<MCNearbyServiceAdvertiserDelegate>)advertiseDelegate
                andSessionDelegate:(id<MCSessionDelegate>)sessionDelegate;

-(void)leaveTheGameRoom;

-(MCSession*)enterThisGameRoom:(MCPeerID*)peerID delegate:(id<MCSessionDelegate>)delegate;

-(void)changeCurrentGamePlayerNo:(GameType)gameType;

@end
