//
//  ZXTransferHistoryCell.m
//  ZX
//
//  Created by 许李超 on 17/8/1.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXTransferHistoryCell.h"
#import "DataBaseManager.h"
#import "FriendNearBy.h"
#import "ZXUser.h"

@interface ZXTransferHistoryCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *senderImg;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *actionTime;
@property (weak, nonatomic) IBOutlet UIImageView *receiverImg;
@property (weak, nonatomic) IBOutlet UILabel *receiverName;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UIImageView *directionForYou;

@end

@implementation ZXTransferHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
	ViewRadius(_bgView, 5);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)renderByRecord:(TransPortRecord*)record{
        
        NSDateFormatter *inFormat = [NSDateFormatter new];
        [inFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        _actionTime.text = [inFormat stringFromDate:record.createTime];
        _fileName.text = record.fileName;
        _fileSize.text = record.fileSize;
        
        ZXUser* current_user = [ZXUser loadSelfProfile];
        
        UIImage* my_avatar_img = current_user.avatar == nil ?
                [UIImage imageNamed:@"head_img"]: current_user.avatar;
        
        if (record.directionForMe){
                _directionForYou.image = [UIImage imageNamed:@"send_info"];
                
                FriendNearBy* sender = [[DataBaseManager getInstance] getFrinedByPeerName:record.senderPeerName];
                
                _senderName.text = sender.name;
                _senderImg.image = sender.avatar == nil ? [UIImage imageNamed:@"head_img"]: sender.avatar;
                
                _receiverName.text = @"我";
                _receiverImg.image = my_avatar_img;
                
        }else{
                _directionForYou.image = [UIImage imageNamed:@"receive_ic"];
                _senderName.text = @"我";
                _senderImg.image = my_avatar_img;
                
                FriendNearBy* receiver = [[DataBaseManager getInstance] getFrinedByPeerName:record.receiverPeerName];
                
                _receiverImg.image = receiver.avatar == nil ? [UIImage imageNamed:@"head_img"]: receiver.avatar;
                _receiverName.text = receiver.name;
        }
        
        [[JCCUtils sharedInstance] graphicsImage:_senderImg];
        [[JCCUtils sharedInstance] graphicsImage:_receiverImg];
}

@end
