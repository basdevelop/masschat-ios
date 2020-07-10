//
//  MusicItemCell.h
//  MassChat
//
//  Created by wsli on 2017/9/7.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"

@interface MusicItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *musicFileName;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
- (IBAction)playOrStop:(id)sender;

-(void)renderByMusicItem:(MusicItem*) musicDetails;

@end
