//
//  PlayerShaiZi.h
//  MassChat
//
//  Created by wsli on 2017/9/15.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPlayer.h"


typedef NS_ENUM(NSInteger, TablePosition) {
        TablePositionMe = 0,
        TablePositionLEFT,
        TablePositionTop,
        TablePositionRIGHT,
};


@interface PlayerShaiZi : CommonPlayer
@property(nonatomic)TablePosition       tablePosition;

+(id)copy:(GamePlayerInfo*)playerInfo from:(id)source withPlaceHolder:(SKNode*)placeHolder;
@end
