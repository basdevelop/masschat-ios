//
//  ZXHistoryMessageViewController.h
//  MassChat
//
//  Created by wsli on 2017/8/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ZXHistoryMessageViewController : JSMessagesViewController
-(id)initWithPeerName:(NSString*)peerName andFriendName:(NSString*)friendName;
@end
