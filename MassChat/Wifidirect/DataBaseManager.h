//
//  DataBaseManager.h
//  MassChat
//
//  Created by wsli on 2017/8/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageBean.h"
#import "FriendNearBy.h"
#import "TransPortRecord.h"
#import "MusicItem.h"

@interface DataBaseManager : NSObject
+ (id)getInstance;

-(NSMutableArray*)loadHistoryMessages:(NSString*)peerName withLastId:(NSInteger*) lastMessageId;

-(void)saveMessage:(MessageBean*)msg withPeerName:(NSString*)peerName;

-(NSMutableDictionary*) loadFriendsHasChatHistory;

-(FriendNearBy*)getFrinedByPeerName:(NSString*)peerName;

-(void)updateFriendInfo:(FriendNearBy*)friendBean;

-(void)removeFriendByPeerName:(NSString*)peerName;

-(NSMutableArray*)loadTransRecord:(NSInteger*) lastMessageId;

-(void)saveTransRecord:(TransPortRecord*)record;

-(void)removeTransRecord:(NSInteger)recordId;

-(void)saveMusic:(MusicItem*)musicItem;

-(NSMutableArray*)loadSavedMusic:(NSInteger*) lastMessageId;

-(void)removeMusicItem:(NSInteger)musicItemId;

-(UIImage*)loadAvatarByPeerName:(NSString*)peerName;

-(void)updateFriendAvatar:(NSData*)data withPeerName:(NSString*)peerName;

@end
