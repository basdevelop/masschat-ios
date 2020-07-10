//
//  ZXChatCell.h
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendNearBy.h"

@interface ZXChatCell : UITableViewCell 
@property (strong, nonatomic) NSString* peerName; 

-(void)renderContent:(FriendNearBy*) friendBean;

-(void)renderContent:(FriendNearBy*) friendBean withOnlineStatus:(BOOL) onStatus;

@end
