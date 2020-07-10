//
//  FriendNearBy.h
//  MassChat
//
//  Created by wsli on 2017/8/23.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface FriendNearBy : NSObject<NSCoding>
@property(nonatomic) BOOL     useDefaultAatar;
@property(nonatomic, strong) NSString*     name;
@property(nonatomic, strong) NSString*     peerName;
@property(nonatomic, strong) NSString*     gender;
@property(nonatomic, strong) NSString*     title;
@property(nonatomic, strong) NSString*     company;
@property(nonatomic, strong) NSString*     address;
@property(nonatomic, strong) NSString*     signature;
@property(nonatomic, copy)   UIImage*      avatar;


@property(nonatomic, strong) MCPeerID*     peerId;
@property(nonatomic, strong) NSString*     lastMessage;
@property(nonatomic, strong) NSDate*       updateTime;
@property(nonatomic) NSInteger             connectStatus;
@property(nonatomic) NSInteger             unreadMessage;


+(id)createDefaultInfo;
+(FriendNearBy*) fromDicData:(NSDictionary*)dic;

-(NSDictionary*) convertToDic;
@end
