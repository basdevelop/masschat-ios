//
//  WifiDirectManager.m
//  MassChat
//
//  Created by wsli on 2017/8/22.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "WifiDirectManager.h"
#import "FriendNearBy.h" 
#import "MessageManager.h"
#import "DataBaseManager.h"
#import "FileTransferManager.h"
#import "InvitationMission.h"
#import "ZXUser.h"

#define MAX_PEER_PEER_SESSION_NO        253
#define MAX_GROUP_SESSION_NO            8
#define SERVICE_TYPE_MASS_CHAT          @"mass-chat"
#define SERVICE_TYPE_P2P_GAME           @"mass-game"
#define DEVICE_PEER_ID_KEY              @"device_peer_id_key"

@interface WifiDirectManager()<MCNearbyServiceAdvertiserDelegate,
MCSessionDelegate, MCNearbyServiceBrowserDelegate>{
        NSMutableDictionary*    _p2pSessionCache;
        NSMutableDictionary*    _iniviteMissionQueue;
        NSMutableDictionary*    _peerDeviceCache;
        FriendNearBy*           _myProfileSaved;
        MCSession*              _gameSession;
}
@end

@implementation WifiDirectManager
@synthesize peerDelegate, sessionDelegate;

static WifiDirectManager *_instance = nil;

+ (id)getInstance {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
               _instance = [[self alloc] init];
        });
        return _instance;
}


-(id) init{
        self = [super init];
        
        if (self) {
                
                _p2pSessionCache = [NSMutableDictionary dictionaryWithCapacity:MAX_PEER_PEER_SESSION_NO];
                _peerDeviceCache = [NSMutableDictionary new];
                _iniviteMissionQueue = [NSMutableDictionary new];
               
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *peer_id_data = [defaults dataForKey:DEVICE_PEER_ID_KEY];
                
                if (nil != peer_id_data) {
                        _mcPeerID = [NSKeyedUnarchiver unarchiveObjectWithData:peer_id_data];
                } else {
                        NSString* device_id = [[UIDevice currentDevice] identifierForVendor].UUIDString;
                        _mcPeerID = [[MCPeerID alloc] initWithDisplayName:device_id];
                        peer_id_data = [NSKeyedArchiver archivedDataWithRootObject:_mcPeerID];
                        [defaults setObject:peer_id_data forKey:DEVICE_PEER_ID_KEY];
                        [defaults synchronize];
                }
                _myProfileSaved = [FriendNearBy new];
                
                [self initSelfAdvertiseData];
                
                _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_mcPeerID
                                       discoveryInfo:[_myProfileSaved convertToDic]
                                     serviceType:SERVICE_TYPE_MASS_CHAT];
                
                _serviceAdvertiser.delegate = self;
                
                _serviceBrowser = [[MCNearbyServiceBrowser alloc]
                                    initWithPeer:_mcPeerID  serviceType:SERVICE_TYPE_MASS_CHAT];
                _serviceBrowser.delegate = self;
        }
        
        return self;
}

#pragma mark -  广播个人信息的代理
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
	didReceiveInvitationFromPeer:(MCPeerID *)peerID
	withContext:(NSData *)context
	invitationHandler:(void (^)(BOOL accept, MCSession * session))invitationHandler{
        
       
        MCSession* session = [self createSession:peerID];
        invitationHandler(YES, session);
        
        if (nil != context){
                InvitationMission* mission = [InvitationMission initWithData:context];
                [mission setIsOwner:NO];
                [_iniviteMissionQueue setObject:mission forKey:peerID.displayName];
        }
}
// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
        NSLog(@"---%@---", error);
}

#pragma mark - 链接状态发生变化
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
        
        switch (state) {
                        
                case MCSessionStateConnecting:
                        NSLog(@"-----peer-%@-is connecting-----", peerID.displayName);
                        break;
                case MCSessionStateNotConnected:{
                        NSLog(@"-*****peer-%@-is MCSessionStateNotConnected*****-", peerID.displayName);
                        FriendNearBy* friend_bean =[_peerDeviceCache
                                                    objectForKey:peerID.displayName];
                        if (nil != friend_bean){
                                [friend_bean setConnectStatus:MCSessionStateNotConnected];
                                
                                if (nil != self.peerDelegate){
                                        [self.peerDelegate friendStateChanges];
                                }
                        }
                        
                        if (nil != self.sessionDelegate){
                                [self.sessionDelegate hasDisConnectedBySession];
                        }
                        [_p2pSessionCache removeObjectForKey:peerID.displayName];
                        
                }break;
                        
                case MCSessionStateConnected:{
                        NSLog(@"-====peer-%@-is MCSessionStateConnected====-", peerID.displayName);
                        FriendNearBy* friend_bean =[_peerDeviceCache
                                                    objectForKey:peerID.displayName];
                        [friend_bean setConnectStatus:MCSessionStateConnected];
                        
                        if (nil != self.peerDelegate){
                                [self.peerDelegate friendStateChanges];
                        }
                        if (nil != self.sessionDelegate){
                                MCSession* session = [_p2pSessionCache objectForKey:peerID];
                                [self.sessionDelegate didConnectedBySession:session];
                        }
                        if (friend_bean.avatar == nil && !friend_bean.useDefaultAatar){
                                [self requestPeerAvatar:peerID session:session];
                        }
                        
                        InvitationMission* mission = [_iniviteMissionQueue objectForKey:peerID.displayName];
                        if (nil != mission){
                                if (InvitationMissionTypeFile ==  mission.type
                                    && NO == mission.isOwner) {
                                        [[FileTransferManager getInstance]
                                         startSendUrlRecource:mission.parameter
                                         bySession:session forPeer:peerID ];
                                }
                                
                                [_iniviteMissionQueue removeObjectForKey:peerID.displayName];
                        }
                } break;
                        
                default:
                        break;
        }
}

-(void)requestPeerAvatar:(MCPeerID*)peerID session:(MCSession*)session{
        NSError* error = nil;
        
        MessageBean* msg = [MessageBean new];
        [msg setType:MessageBeanTypeAvatarReq];
        [msg setText:_mcPeerID.displayName];
        
        [session sendData:[MessageBean generateData:msg]
                  toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
        
        if (error){
                NSLog(@"发送消息失败:%@", error);
        }
}

#pragma mark - 收到消息
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
        
        MessageBean* msg_bean = [MessageBean initWithData:data];
        [msg_bean setInMsg:YES];
        NSLog(@"%@",[msg_bean toString]);
        
        switch (msg_bean.type) {
                     
                default:
                case MessageBeanTypeChatMsg:{
                        FriendNearBy * friend_bean = [_peerDeviceCache objectForKey:peerID.displayName];
                        [friend_bean setLastMessage:msg_bean.text];
                        
                        NSUInteger msg_no_to_cache = [[MessageManager getInstance] receiveMessage:msg_bean withPeerName:peerID.displayName];
                        if (msg_no_to_cache > 0){
                                [friend_bean setUnreadMessage:msg_no_to_cache];
                                [self.peerDelegate friendStateChanges];
                        }
                        
                }break;
                        
                case MessageBeanTypeTransCtl:{
                        
                        MCSession* cached_session = [_p2pSessionCache objectForKey:peerID.displayName];
                        
                        [[FileTransferManager getInstance] startSendUrlRecource:msg_bean.text
                                                           bySession:cached_session
                                                           forPeer:peerID ];
                } break;
                        
                case MessageBeanTypeAvatarReq:{
                        
                        ZXUser* current_user = [ZXUser loadSelfProfile];
                        
                        NSData* data =  UIImagePNGRepresentation(current_user.avatar);
                        MessageBean* msg = [MessageBean new];
                        msg.type = MessageBeanTypeAvatarResp;
                        msg.binData = data;
                        
                        NSError* error = nil;
                        [session sendData:[MessageBean generateData:msg]
                                  toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
                        
                        if (error){
                                NSLog(@"发送消息失败:%@", error);
                        }
                }break;
                case MessageBeanTypeAvatarResp:{
                        NSData* data = msg_bean.binData;
                        FriendNearBy * friend_bean = [_peerDeviceCache objectForKey:peerID.displayName];
                        friend_bean.avatar = [UIImage imageWithData: data];
                        [self.peerDelegate friendStateChanges];
                        [[DataBaseManager getInstance] updateFriendAvatar:data withPeerName:peerID.displayName];
                }break;
        }
} 


#pragma mark - 以url的方式传输文件.
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID  withProgress:(NSProgress *)progress{
        
        [[FileTransferManager getInstance] startReceiveUrlRecource:resourceName
                                           bySession:session
                                           forPeer:peerID withProgress:progress];
        
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
        
        [[FileTransferManager getInstance] didFinishedReceive:resourceName
                                                atURL:localURL
                                                forPeer:peerID
                                                    withError:error];
}


//--------useless interface------------
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
}
#pragma mark - delegate for MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(NSDictionary<NSString *, NSString *> *)info{
        
        FriendNearBy* friend_bean = [FriendNearBy fromDicData:info];
        [friend_bean setPeerId:peerID];
        [friend_bean setConnectStatus:MCSessionStateNotConnected];
        
        UIImage* avatar = [[DataBaseManager getInstance] loadAvatarByPeerName:peerID.displayName];
        [friend_bean setAvatar:avatar];
        
        
        [_peerDeviceCache setObject:friend_bean forKey:peerID.displayName];
        if (nil != self.peerDelegate){
                [self.peerDelegate friendStateChanges];
        }
        
        [[DataBaseManager getInstance] updateFriendInfo:friend_bean];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
        [_peerDeviceCache removeObjectForKey:peerID.displayName];
        if (nil != self.peerDelegate){
                [self.peerDelegate friendStateChanges];
        }
}

#pragma mark - work work work.用户自定义的功能函数

-(NSArray*)getPeerDeviceList{
        return _peerDeviceCache.allValues;
}

-(NSMutableDictionary*)getPeerDeviceDic{
        return _peerDeviceCache;
}

- (MCSession*) createSession:(MCPeerID*) peerId{
        MCSession* session = [_p2pSessionCache objectForKey:peerId.displayName];
        if (nil == session){
                session = [[MCSession alloc] initWithPeer:_mcPeerID];
                session.delegate = self;
                [_p2pSessionCache setObject:session forKey:peerId.displayName];
        }
        return session;
}

-(void)inviteThisFriend:(MCPeerID*)peerId{
        MCSession* session = [self createSession:peerId];
        [_serviceBrowser invitePeer:peerId toSession:session withContext:nil timeout:30];

}

-(void)startShowMyself{
        [_serviceAdvertiser startAdvertisingPeer];
}

-(void)initSelfAdvertiseData{
        ZXUser* current_user = [ZXUser loadSelfProfile];
        
        [_myProfileSaved setName:current_user.nickName];
        [_myProfileSaved setGender:current_user.gender];
        [_myProfileSaved setSignature:current_user.signature];
        [_myProfileSaved setUseDefaultAatar:current_user.avatar == nil];
}

-(void)restartShowMySelf{
        [_serviceAdvertiser stopAdvertisingPeer];
        
        [self initSelfAdvertiseData];
        
        _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_mcPeerID
                                                                discoveryInfo:[_myProfileSaved convertToDic]
                                                                serviceType:SERVICE_TYPE_MASS_CHAT];
        _serviceAdvertiser.delegate = self;
        
        [_serviceAdvertiser startAdvertisingPeer];
}

-(void)findNearByFriends{
        [_serviceBrowser startBrowsingForPeers];
}

-(FriendNearBy*)getFriendByPeerId:(MCPeerID*)peerID{
        return [_peerDeviceCache objectForKey:peerID.displayName];
}

-(BOOL)sendMessage:(MessageBean*)msg withPeerName:(NSString*) peerName{
        MCSession* session = [_p2pSessionCache objectForKey:peerName];
        if (nil == session){
                return NO;
        }
        FriendNearBy * friend_bean = [_peerDeviceCache objectForKey:peerName];
        MCPeerID* peerId = [friend_bean peerId];
        if (nil == peerId){
                return NO;
        }
        
        if (MessageBeanTypeChatMsg == msg.type){
                [friend_bean setLastMessage:[msg text]];
        }
        
        NSError* error = nil;
        
        [session sendData:[MessageBean generateData:msg]
                  toPeers:@[peerId] withMode:MCSessionSendDataReliable error:&error];
        
        if (error){
                NSLog(@"发送消息失败:%@", error);
                return NO;
        }
        
        return YES;
}

-(BOOL) connectPeer:peer_name forTransport:path{
        FriendNearBy* friend_bean =[_peerDeviceCache
                                    objectForKey:peer_name];
        if (nil == friend_bean){
                NSLog(@"对方手机并未开启该服务");
                //TODO::如果失败，提示用户。
                return NO;
        }
        
        InvitationMission* mission =[_iniviteMissionQueue objectForKey:peer_name];
        if (nil != mission){
                NSLog(@"当前有一个任务正在处理，请稍后再试");
                //TODO::如果失败，提示用户。
                return NO;

        }
        
        mission = [InvitationMission new];
        [mission setType:InvitationMissionTypeFile];
        [mission setParameter:path];
        [mission setIsOwner:YES];
        MCSession* session = [self createSession:friend_bean.peerId];
        [_serviceBrowser invitePeer:friend_bean.peerId toSession:session
                        withContext:[InvitationMission generateData:mission] timeout:30];
        [_iniviteMissionQueue setObject:mission forKey:peer_name];
        
        return YES;
        
}

#pragma mark - 文件传输协议

-(MCSession*)getCachedSession:(NSString*)peerName{
        return  [_p2pSessionCache objectForKey:peerName];
}

#pragma mark - 游戏逻辑
-(void)createGameServersBrowser:(id<MCNearbyServiceBrowserDelegate>)delegate{
        
        NSString* device_id = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        
        _gamePeerID = [[MCPeerID alloc] initWithDisplayName:device_id];
        
        _gameServerBrowser = [[MCNearbyServiceBrowser alloc]
                           initWithPeer:_gamePeerID  serviceType:SERVICE_TYPE_P2P_GAME];
        
        _gameServerBrowser.delegate = delegate;
        
        [_gameServerBrowser startBrowsingForPeers];
}


-(MCSession*)createGameRoom:(GameServiceInfoBean*)gameBean
                withAdvertiseDelegate:(id<MCNearbyServiceAdvertiserDelegate>)advertiseDelegate
                andSessionDelegate:(id<MCSessionDelegate>)sd{
        
        
        [_gameServerBrowser stopBrowsingForPeers];
        
        _gameServierAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_gamePeerID
                                                               discoveryInfo:[gameBean convertToDic]
                                                        serviceType:SERVICE_TYPE_P2P_GAME];
        _gameServierAdvertiser.delegate = advertiseDelegate;
        
        [_gameServierAdvertiser startAdvertisingPeer];
        
        _gameSession = [[MCSession alloc] initWithPeer:_gamePeerID];
        
        _gameSession.delegate = sd;
        
        return _gameSession;
}
-(void)leaveTheGameRoom{
        
        [_gameServerBrowser startBrowsingForPeers];
        
        if (_gameSession){
                [_gameSession disconnect];
                _gameSession = nil;
        }
        
        if (_gameServierAdvertiser){
                [_gameServierAdvertiser stopAdvertisingPeer];
                _gameServierAdvertiser = nil;
        }
}

-(MCSession*)enterThisGameRoom:(MCPeerID*)peerID delegate:(id<MCSessionDelegate>)delegate{
        
        [_gameServerBrowser stopBrowsingForPeers];
        
        NSArray* connected_peers = _gameSession.connectedPeers;
        
        if ([connected_peers containsObject:peerID]){
                return _gameSession;
        }
        
        _gameSession = [[MCSession alloc] initWithPeer:_gamePeerID];
        
        _gameSession.delegate = delegate;
        
        [_gameServerBrowser invitePeer:peerID toSession:_gameSession withContext:nil timeout:30];
        
        return _gameSession;
}

-(void)readvertiseInfo:(GameType)gameType{
        
        id<MCNearbyServiceAdvertiserDelegate> delegate = _gameServierAdvertiser.delegate;
        
        NSMutableDictionary* parameter = [_gameServierAdvertiser.discoveryInfo mutableCopy];
        NSString* current_no = [NSString stringWithFormat:@"%u", (int)_gameSession.connectedPeers.count + 1];
        [parameter setObject:current_no forKey:@"playerNo"];

        MCNearbyServiceAdvertiser* new_advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_gamePeerID
                                                                   discoveryInfo:parameter
                                                             serviceType:SERVICE_TYPE_P2P_GAME];
        new_advertiser.delegate = delegate;

        [new_advertiser startAdvertisingPeer];
        
        _gameServierAdvertiser = new_advertiser;
}

-(void)changeCurrentGamePlayerNo:(GameType)gameType{
        
        if (nil != _gameServierAdvertiser){
                [_gameServierAdvertiser stopAdvertisingPeer];
        
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200.0 * NSEC_PER_MSEC));
                dispatch_after(time, dispatch_get_main_queue(), ^{
                        [self readvertiseInfo:gameType];
                });
        }
}
@end
