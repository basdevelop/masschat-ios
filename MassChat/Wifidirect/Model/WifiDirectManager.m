//
//  WifiDirectManager.m
//  MassChat
//
//  Created by wsli on 2017/8/22.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "WifiDirectManager.h"
#import "FriendNearBy.h"

#define MAX_PEER_PEER_SESSION_NO        253
#define MAX_GROUP_SESSION_NO            8
#define SERVICE_TYPE_MASS_CHAT          @"mass-chat"
#define DEVICE_PEER_ID_KEY              @"device_peer_id_key"
#define MY_PROFILE_DATA_KEY             @"my_profile_data_key"

@interface WifiDirectManager()<MCNearbyServiceAdvertiserDelegate,
MCSessionDelegate, MCNearbyServiceBrowserDelegate>{
        NSMutableDictionary*    _p2pSessionCache;
        NSMutableDictionary*    _peerDeviceCache;
        FriendNearBy*           _myProfileSaved;
        
//NSMutableDictionary*    _groupSessionCache;//TODO:: Group talk and game.
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
//                _groupSessionCache = [NSMutableDictionary dictionaryWithCapacity:MAX_GROUP_SESSION_NO];
               
                
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
                
                NSData* profile_data = [defaults dataForKey:MY_PROFILE_DATA_KEY];
                if (nil == profile_data){
                        _myProfileSaved = [FriendNearBy createDefaultInfo];
                }else{
                        _myProfileSaved = [NSKeyedUnarchiver unarchiveObjectWithData:profile_data];
                }
                
                
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

-(NSArray*)getPeerDeviceList{
        return _peerDeviceCache.allValues;
}

#pragma mark ----implements for MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
	didReceiveInvitationFromPeer:(MCPeerID *)peerID
	withContext:(NSData *)context
	invitationHandler:(void (^)(BOOL accept, MCSession * session))invitationHandler{
        
        //TODO:: check if it's an old friends, if not ,set the inviting message.
        //TODO:: check how to set context for group session.
//        
        MCSession* session = [[MCSession alloc] initWithPeer:_mcPeerID];
        session.delegate = self;
        [_p2pSessionCache setObject:session forKey:peerID.displayName];
        
        invitationHandler(true, session);
}
// Advertising did not start due to an error.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
        //TODO:: warning.
}

#pragma mark ----implements for mcsession delegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
        //TODO::notify or fresh the status of friend list.
        
        switch (state) {
                        
                case MCSessionStateConnecting:
                        NSLog(@"-----peer-%@-is connecting-----", peerID.displayName);
                        break;
                case MCSessionStateNotConnected:{
                        
                        FriendNearBy* friend_bean =[_peerDeviceCache
                                                    objectForKey:peerID.displayName];
                        [friend_bean setConnectStatus:MCSessionStateNotConnected];
                        
                        if (nil != self.peerDelegate){
                                [self.peerDelegate friendDisconnected];
                        }
                        
                        if (nil != self.sessionDelegate){
                                [self.sessionDelegate hasDisConnectedBySession];
                        }
                }break;
                        
                case MCSessionStateConnected:{
                        
                        FriendNearBy* friend_bean =[_peerDeviceCache
                                                    objectForKey:peerID.displayName];
                        [friend_bean setConnectStatus:MCSessionStateConnected];
                        
                        if (nil != self.peerDelegate){
                                [self.peerDelegate friendConnected];
                        }
                        if (nil != self.sessionDelegate){
                                MCSession* session = [_p2pSessionCache objectForKey:peerID];
                                [self.sessionDelegate didConnectedBySession:session];
                        }
                } break;
                        
                default:
                        break;
        }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
}

//--------useless interface------------
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName
	fromPeer:(MCPeerID *)peerID  withProgress:(NSProgress *)progress{
        
}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName
	fromPeer:(MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error{
}

#pragma mark ----delegate for MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(NSDictionary<NSString *, NSString *> *)info{
        NSLog(@"---id=%@===info=%@", peerID.displayName, info);
        FriendNearBy* friend_bean = [FriendNearBy fromDicData:info];
        [friend_bean setPeerId:peerID];
        [friend_bean setConnectStatus:MCSessionStateNotConnected];
        
        [_peerDeviceCache setObject:friend_bean forKey:peerID.displayName];
        if (nil != self.peerDelegate){
                [self.peerDelegate friendStateChanges];
        }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
        [_peerDeviceCache removeObjectForKey:peerID.displayName];
        if (nil != self.peerDelegate){
                [self.peerDelegate friendStateChanges];
        }
}

#pragma mark - work work work.
-(void)inviteThisFriend:(MCPeerID*)peerId{
        MCSession* session = [_p2pSessionCache objectForKey:peerId.displayName];
        if (nil == session){
                MCSession* session = [[MCSession alloc] initWithPeer:_mcPeerID];
                session.delegate = self;
                [_p2pSessionCache setObject:session forKey:peerId.displayName];
                
                [_serviceBrowser invitePeer:peerId toSession:session withContext:nil timeout:30];
        }
}

-(void)startShowMyself{
        [_serviceAdvertiser startAdvertisingPeer];
}

-(void)findNearByFriends:(id<WifiDirectPeerDelegate>) delegate{
        [_serviceBrowser startBrowsingForPeers];
        self.peerDelegate = delegate;
}

-(FriendNearBy*)getFriendByPeerId:(MCPeerID*)peerID{
        return [_peerDeviceCache objectForKey:peerID.displayName];
}

@end
