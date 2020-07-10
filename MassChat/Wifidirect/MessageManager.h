//
//  MessageManager.h
//  MassChat
//
//  Created by wsli on 2017/8/25.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageBean.h"

@protocol MessageManagerDelegate <NSObject>
- (void)didReceivedMessage:(MessageBean*)msg;
@end

@interface MessageManager : NSObject

+ (id)getInstance;

-(void)registerDelegate:(id<MessageManagerDelegate>) delegate withPeerName:(NSString*) peerName;
-(void)unregisterDelegateByPeerName:(NSString*) peerName;
-(Boolean)sendMessage:(MessageBean*)msg withPeerName:(NSString*) peerName;
-(NSUInteger)receiveMessage:(MessageBean*)msg withPeerName:(NSString*) peerName;

@end
