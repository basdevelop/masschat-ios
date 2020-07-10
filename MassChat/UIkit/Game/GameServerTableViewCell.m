//
//  GameServerTableViewCell.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "GameServerTableViewCell.h" 

@interface GameServerTableViewCell(){
        GameServiceInfoBean*    _currentRoomInfo;
}
@end

@implementation GameServerTableViewCell

- (void)awakeFromNib {
        [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)joinThisGame:(UIButton *)sender {
        
        [self.parentController joinTheGame:_currentRoomInfo];
}

-(void)renderContent:(GameServiceInfoBean*)serverBean{
        
        _currentRoomInfo = serverBean;
        
        NSString* image_name = @"";
        switch (serverBean.gameType) {
                default:
                case GameTypeShaiZiFace:{
                        image_name = @"dice_bg";
                        _gameDescTitle.text = @"大话骰";
                        _gameDescDetails.text = @"(面对面)";
                        }
                        break;
                case GameTypeShaiZiStranger:{
                        image_name = @"dice_Stranger_bg";
                        _gameDescTitle.text = @"大话骰";
                        _gameDescDetails.text = @"(陌生人)";
                        }
                        break;
                case GameTypeDouDiZhu:{
                        image_name = @"poker_bg";
                        _gameDescTitle.text = @"斗地主";
                        _gameDescDetails.text = @"";
                        }
                        break;
        }
        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:image_name] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.f] ];
        
        _serverInstanceName.text = serverBean.ownersName;
        
        _playersNoInGame.text = [NSString stringWithFormat:@"玩家:%ld人", (long)serverBean.playerNo];
}

@end
