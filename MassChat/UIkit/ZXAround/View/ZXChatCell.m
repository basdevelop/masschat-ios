//
//  ZXChatCell.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXChatCell.h"
#import "DataBaseManager.h"

@interface ZXChatCell(){
        Boolean  _onlineStatus;
}

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *messageCount;
@property (weak, nonatomic) IBOutlet UILabel *signature;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *lastMessage;

@end

@implementation ZXChatCell
@synthesize peerName;

- (void)awakeFromNib {
        [super awakeFromNib];
        CGFloat  height = KEdqCellHeight(70); 
        
        ViewRadius(_messageCount, height * 5 / 38);
        
        _onlineStatus = YES; 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)renderContent:(FriendNearBy*) friendBean{
        _name.text = friendBean.name;
        _signature.text = friendBean.signature;
        _lastMessage.text = friendBean.lastMessage;
        
        if (friendBean.unreadMessage >0){
            _messageCount.text = [NSString stringWithFormat:@"%ld", (long)friendBean.unreadMessage];
            [_messageCount setHidden:NO];
        }else{
            _messageCount.text = 0;
            [_messageCount setHidden:YES];
        }
        if (friendBean.avatar == nil){
                _avatarView.image = [UIImage imageNamed:@"head_img"];
        }else{
                _avatarView.image = friendBean.avatar;
                [[JCCUtils sharedInstance] graphicsImage:_avatarView];
        }
}

-(void)renderContent:(FriendNearBy*) friendBean withOnlineStatus:(BOOL) onStatus{
        _onlineStatus = onStatus;
        if (onStatus){
                peerName = friendBean.peerId.displayName;
        }else{
                peerName = friendBean.peerName;
        }
        
        [self renderContent:friendBean];
}

@end
