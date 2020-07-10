//
//  Card.h
//  MassChat
//
//  Created by wsli on 2017/9/12.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CardType) {
        CardTypeRedPeach = 0,
        CardTypeRedTile,
        CardTypeBlackPeach,
        CardTypeBlackTile,
        CardTypeLittleKing,
        CardTypeBigKing
};

@interface Card : NSObject

@property(nonatomic)int value;
@property(nonatomic)int tag;
@property(nonatomic)CardType type;

@end
