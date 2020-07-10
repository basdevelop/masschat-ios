//
//  DouDiZhuLogic.h
//  MassChat
//
//  Created by wsli on 2017/9/12.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerDouDiZhu.h"
#import "CommonGameLogic.h"

@interface DouDiZhuLogic : CommonGameLogic
@property(nonatomic, strong, readonly)NSMutableArray*   orignalCards;
@property(nonatomic, strong) NSMutableArray*            shuffledCards;
@property(nonatomic, strong) PlayerDouDiZhu             *playerMySelf, *playerRight, *playerLeft;

+(instancetype)getInstance;

-(void)shuffle;

-(void)dispatchCardsToPlayer;

@end
