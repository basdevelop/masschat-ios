//
//  MusicItemCell.m
//  MassChat
//
//  Created by wsli on 2017/9/7.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "MusicItemCell.h"
#import <AVFoundation/AVFoundation.h>

@interface MusicItemCell()<AVAudioPlayerDelegate>{
        NSURL*          _musicPath;
        AVAudioPlayer*  _avAudioPlayer;
}
@end

@implementation MusicItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)playOrStop:(id)sender {
        if (_controlButton.tag == NO){
                NSError* error = nil;
                _avAudioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:_musicPath error:&error];
                if (error){
                        NSLog(@"打开音频文件失败:%@", error);
                }
                _avAudioPlayer.volume = 1;
                _avAudioPlayer.numberOfLoops = 0;
                _controlButton.tag = YES;
                _avAudioPlayer.delegate = self;
                [_controlButton setTitle:@"停止" forState:UIControlStateNormal];
                [_avAudioPlayer play];
                
        }else{
                if (nil != _avAudioPlayer){
                        [_avAudioPlayer stop];
                        _avAudioPlayer = nil;
                }
                _controlButton.tag = NO;
                [_controlButton setTitle:@"播放" forState:UIControlStateNormal];
        }
}

-(void)renderByMusicItem:(MusicItem*) musicDetails{
        _musicFileName.text = [musicDetails fileName];
        [_controlButton setTitle:@"播放" forState:UIControlStateNormal];
        _controlButton.tag = NO;
        _musicPath = [musicDetails fileUrl];
        _avAudioPlayer = nil;
}


#pragma mark - 播放音乐的回调处理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
        if (nil != _avAudioPlayer){
                [_avAudioPlayer stop];
                _avAudioPlayer = nil;
        }
        _controlButton.tag = NO;
        [_controlButton setTitle:@"播放" forState:UIControlStateNormal];
}

@end
