//
//  DouDiZhuLogic.m
//  MassChat
//
//  Created by wsli on 2017/9/12.
//  Copyright © 2017年 众信. All rights reserved.
//
#import "Card.h"
#import "DouDiZhuLogic.h"

#define CARD_NO_IN_ONE_POKER    54

@implementation DouDiZhuLogic
@synthesize shuffledCards, orignalCards, playerLeft, playerRight, playerMySelf;

static  DouDiZhuLogic*  _instance = nil;

+(instancetype)getInstance{
        
        static dispatch_once_t once_token;
        
        dispatch_once(&once_token, ^{
                _instance = [[DouDiZhuLogic alloc] init];
        });
        
        return _instance;
}
-(instancetype)init{
        
        if (self = [super init]){
                orignalCards    = [NSMutableArray arrayWithCapacity:CARD_NO_IN_ONE_POKER];
                shuffledCards   = [NSMutableArray arrayWithCapacity:CARD_NO_IN_ONE_POKER];
                for (int i = 0; i < CARD_NO_IN_ONE_POKER - 2; i++){
                        Card* card = [Card new];
                        [card setValue:(i % 13 + 1)];
                        [card setType:(CardType)(i / 13)];
                        [card setTag:i];
                        
                        [orignalCards addObject:card];
                }
                
                Card* little_king = [Card new];
                [little_king setValue:52];
                [little_king setType:(CardTypeLittleKing)];
                [little_king setTag:52];
                [orignalCards addObject:little_king];
                
                Card* big_king = [Card new];
                [big_king setValue:53];
                [big_king setType:(CardTypeBigKing)];
                [big_king setTag:53];
                [orignalCards addObject:big_king];
                
//                NSLog(@"====orignalCards====");
//                [orignalCards enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        Card* card =  (Card*)obj;
//                        NSLog(@"\n tag=%d value=%d type=%lu",card.tag, card.value, (unsigned long)card.type);
//                }];
        }
        
        return self;
}

-(void)shuffle{
        shuffledCards = [orignalCards mutableCopy];
        for (int i = 0; i < CARD_NO_IN_ONE_POKER; i++){
                int r = (int) (arc4random() % CARD_NO_IN_ONE_POKER);
                
                Card* card_i = [shuffledCards objectAtIndex:i];
                Card* card_r = [shuffledCards objectAtIndex:r];
                
                if (card_i.tag != card_r.tag){
                        [shuffledCards setObject:card_i atIndexedSubscript:r];
                        [shuffledCards setObject:card_r atIndexedSubscript:i];
                }
        }
        
//        NSLog(@"====shuffledCards====");
//        [shuffledCards enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                Card* card =  (Card*)obj;
//                NSLog(@"\n tag=%d value=%d type=%lu",card.tag, card.value, (unsigned long)card.type);
//        }];
}

-(void)dispatchCardsToPlayer{
        
}
@end
