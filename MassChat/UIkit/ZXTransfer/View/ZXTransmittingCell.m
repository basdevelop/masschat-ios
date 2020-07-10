//
//  ZXTransmittingCell.m
//  ZX
//
//  Created by 许李超 on 17/7/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXTransmittingCell.h"
#import "ASProgressPopUpView.h"
#import "ZXUser.h"
@interface ZXTransmittingCell (){
        NSString*       _totalSizeStr;
}

@property (weak, nonatomic) IBOutlet UIProgressView *transProgress;
@property (weak, nonatomic) IBOutlet UILabel *progressDesc;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIImageView *tipsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *peerFriendAvatar;

@end

@implementation ZXTransmittingCell

- (void)awakeFromNib {
        [super awakeFromNib];
//        self.transProgress.popUpViewAnimatedColors = @[RGBCOLOR(205, 155, 255),RGBCOLOR(130, 135, 190)];
}

-(void)cellWithTransmit{
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated]; 
}


-(void)renderByTaskInfo:(TransportTask*)task{
        
        NSProgress *progress = task.progress;
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        
        _fileName.text = task.fileName;
        if (TransportTaskTypeSend == task.direction){
                _tipsIcon.image = [UIImage imageNamed:@"receive_ic"];
        }else{
                _tipsIcon.image = [UIImage imageNamed:@"send_info"];
        }
        
        ZXUser* current_user = [ZXUser loadSelfProfile];
        _peerFriendAvatar.image =  current_user.avatar == nil ?
                [UIImage imageNamed:@"head_img"]: current_user.avatar;
        [[JCCUtils sharedInstance] graphicsImage:_peerFriendAvatar];
        
        _totalSizeStr = [TransportTask calculateFileSize:progress.totalUnitCount];
        
}

#pragma mark - 更新进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
        
        NSProgress *progress = (NSProgress *)object;
        NSString*  desc = [NSString stringWithFormat:@"%@(%@)", _totalSizeStr, progress.localizedDescription];;
        double value = progress.fractionCompleted;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
                [self performSelector:@selector(showProgress:withValue:) withObject:desc withObject:[NSNumber numberWithDouble:value]];
        });
        
        if (progress.fractionCompleted == 1.0) {
                [progress removeObserver:self forKeyPath:@"fractionCompleted" context:nil];
        }
}

-(void)showProgress:(NSString*)desc withValue:(NSNumber*) value{
        dispatch_async(dispatch_get_main_queue(), ^{
                _progressDesc.text = desc;
                [self.transProgress setProgress:[value floatValue] animated:NO];
        });
}

@end
