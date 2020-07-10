//
//  ShaiZiScene.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ShaiZiScene.h"
#import "ShaiZiLogic.h"
#import "ZXUser.h"
#import "dice.h"
#import "WifiDirectManager.h"

#define PLAYER_POSITION_HOLDER_NAME     @"PLAYER_HOLDER_%ld"
#define START_ACTION_NODE_NAME          @"startGameButton"
#define START_TIPS_NODE_NAME            @"waitingStartTips"
#define WAITING_RESULT_TIPS             @"dice_waiting_back"
#define SHOW_RESULT_NODE_NAME           @"showGameResultButton"
#define DICE_RESULT_ME_PLACE_HOLDER     @"DICE_RESULT_ME"
#define DICE_RESULT_LEFT_PLACE_HOLDER   @"DICE_RESULT_1"
#define DICE_RESULT_TOP_PLACE_HOLDER    @"DICE_RESULT_2"
#define DICE_RESULT_RIGHT_PLACE_HOLDER  @"DICE_RESULT_3"
#define QR_CODE_IMAGE                   @"QR_CODE_IMAGE"

@interface ShaiZiScene(){
        SKSpriteNode*           _startGameButton;
        SKSpriteNode*           _startGameTips;
	PlayerShaiZi*           _playerMySelf;
	SKSpriteNode*           _returnBackBtn; 
        SKSpriteNode*           _waitingResultTips;
        SKSpriteNode*           _showGameResultButton;
        SKSpriteNode*           _qrCodeImageShowNode;
        CGPoint                 _originalQRCodePos;
}
@end

@implementation ShaiZiScene
@synthesize gameType;

- (void)sceneDidLoad{
        
        self.playersInGame = [[NSMutableDictionary alloc] initWithCapacity:MAX_PLAYER_IN_THIS_GAME];
        
        [[ShaiZiLogic getInstance] initGame:self];
        
        [self initGameElement];
}

-(void)initGameElement{
        
        _returnBackBtn = (SKSpriteNode*)[self childNodeWithName:@"return_back"];
        
        ZXUser* current_user = [ZXUser loadSelfProfile];
        
        NSString* name = current_user.name == nil ? current_user.nickName:current_user.name;
        
        _playerMySelf = [[PlayerShaiZi alloc] init:self
                                      withNodeName:@"player_avatar_me"
                                       avatarImage:current_user.avatar nickName:name];
        
        TablePosition available_pos = [[ShaiZiLogic getInstance] findEmptyTablePosition];
        _playerMySelf.tablePosition = available_pos;
        
        [[ShaiZiLogic getInstance] addPlayer:_playerMySelf];
        
        NSString* peer_name = [[WifiDirectManager getInstance] gamePeerID].displayName;
        [self.playersInGame setObject:_playerMySelf forKey:peer_name]; 
        
        _startGameButton = (SKSpriteNode*)[self childNodeWithName:START_ACTION_NODE_NAME];
        [_startGameButton setHidden:YES];
        
        _startGameTips = (SKSpriteNode*)[self childNodeWithName:START_TIPS_NODE_NAME];
        [_startGameTips setHidden:YES];
        
        _waitingResultTips = (SKSpriteNode*)[self childNodeWithName:WAITING_RESULT_TIPS];
        [_waitingResultTips setHidden:YES];
        
        _showGameResultButton = (SKSpriteNode*)[self childNodeWithName:SHOW_RESULT_NODE_NAME];
        [_showGameResultButton setHidden:YES];
        
}

-(void)setQrCodeImage:(UIImage *)qrCodeImage{
        _qrCodeImageShowNode = (SKSpriteNode*)[self childNodeWithName:QR_CODE_IMAGE];
        _originalQRCodePos = _qrCodeImageShowNode.position;
        SKTexture* avatar_texture = [SKTexture textureWithImage:qrCodeImage];
        [_qrCodeImageShowNode setTexture:avatar_texture];
}

-(SKSpriteNode*) getDiceByValue:(int)diceValue withIndex:(int)index byOpertion:(CGPoint)operation {

        SKSpriteNode* dice;
        switch (diceValue) {
                case 1:{
                        dice = [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_01];
                }break;
                case 2:{
                        dice =  [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_02];
                }break;
                case 3:{
                        dice =  [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_03];
                }break;
                case 4:{
                        dice =  [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_04];
                }break;
                case 5:{
                        dice =  [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_05];
                }break;
                case 6:{
                        dice =  [SKSpriteNode spriteNodeWithTexture:DICE_TEX_DICE_06];
                }break;
        }
        CGPoint node_position;
        CGSize  node_size = dice.size;
        float dice_gap = 10.f;
        switch (index) {
                case 0:
                default:
                        node_position = CGPointMake(-2 * operation.x * (node_size.width + dice_gap),
                                                    2* operation.y * (node_size.height + dice_gap));
                break;
                case 1:
                        node_position = CGPointMake(- operation.x *(node_size.width + dice_gap),
                                                    operation.y * (node_size.height + dice_gap));
                break;
                case 2:
                        node_position = CGPointMake(0, 0);
                break;
                case 3:
                        node_position = CGPointMake(operation.x * (node_size.width + dice_gap),
                                                    -operation.y * (node_size.height + dice_gap));
                break;
                case 4:
                        node_position = CGPointMake(2 * operation.x * (node_size.width + dice_gap),
                                                    -2 * operation.y * (node_size.height + dice_gap));
                break;
        }
        
        dice.position = node_position;
        dice.zPosition = 7;
        
        return dice;
}


-(void)showResultOfMine {
        NSMutableArray* result_of_me = [ShaiZiLogic getInstance].diceRandomResultOfMe;
        SKNode* result_place_holder = [self childNodeWithName:DICE_RESULT_ME_PLACE_HOLDER];
        CGPoint operation = CGPointMake(1, 0);
        
        for (int i = 0; i < DICE_NOMBER_PER_PLAYER; i++){
                NSNumber* dice_value = result_of_me[i];
                SKSpriteNode* dice = [self getDiceByValue:[dice_value intValue] withIndex:i byOpertion:operation];
                [result_place_holder addChild:dice];
        }
        
        [_showGameResultButton setHidden:NO];
}

-(void)showWaitingResultActions:(void (^)(void))block{
        
         [_waitingResultTips setHidden:NO];
        
        SKSpriteNode* rolling_ring = (SKSpriteNode*)[_waitingResultTips childNodeWithName:@"dice_waiting_ring"];
        SKAction* rolling_action = [SKAction actionNamed:@"diceRingRolling"];
        [rolling_ring runAction:rolling_action];
        
        
        SKAction* dice_action = [SKAction actionNamed:@"diceAnimations"];
        SKSpriteNode* dice = (SKSpriteNode*)[_waitingResultTips childNodeWithName:@"dice_rolling"];
        [dice runAction:dice_action completion:block];
}

-(void)showStartGameButtons{
        
        if ([[ShaiZiLogic getInstance] canStartGame]){
                if (self.parentCtroller.isRoomOwner){
                        [_startGameButton setHidden:NO];
                }else{
                        [_startGameTips setHidden:NO];
                }
        }
}

-(void)resetGame{
        [super resetGame];
        if (self.parentCtroller.isRoomOwner){
                 [_startGameButton setHidden:NO];
         }else{
                 [_startGameTips setHidden:NO];
         }
}

-(void)cleanLastResult{
        [super cleanLastResult];
        [[self childNodeWithName:DICE_RESULT_ME_PLACE_HOLDER] removeAllChildren];
        [[self childNodeWithName:DICE_RESULT_LEFT_PLACE_HOLDER] removeAllChildren];
        [[self childNodeWithName:DICE_RESULT_TOP_PLACE_HOLDER] removeAllChildren];
        [[self childNodeWithName:DICE_RESULT_RIGHT_PLACE_HOLDER] removeAllChildren];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        NSLog(@"----选中的名字:%@---", node.name);

        if ([node.name isEqualToString:@"return_back"]) {
                [self exitGame];
        }else if ([node.name isEqualToString:START_ACTION_NODE_NAME]
                  || (node.parent &&
                      [node.parent.name isEqualToString:START_ACTION_NODE_NAME])){
                [self startGame];
        }else if  ([node.name isEqualToString:SHOW_RESULT_NODE_NAME]
             || (node.parent &&
                 [node.parent.name isEqualToString:SHOW_RESULT_NODE_NAME])){
                 
                 [_showGameResultButton setHidden:YES];
                 [[ShaiZiLogic getInstance] discoverResult];
                 [self showWaitingResultActions:^{
                         [_waitingResultTips setHidden:YES];
                         [self resetGame];
                 }];
	}else if ([node.name isEqualToString:QR_CODE_IMAGE]){
                
                if (_qrCodeImageShowNode.xScale <=1.f){
                        _qrCodeImageShowNode.position = CGPointMake(0.0f, 0.0f);
                        [_qrCodeImageShowNode setScale:4.f];
                }else{
                        _qrCodeImageShowNode.position = _originalQRCodePos;
                        [_qrCodeImageShowNode setScale:1.f];
                }
        }
}


-(void)startGame{

        [super startGame];

        if (self.parentCtroller.isRoomOwner){
                [[ShaiZiLogic getInstance] notifyPlayerToStart];
                [_startGameButton setHidden:YES];
        }
        
        [[ShaiZiLogic getInstance] startGame];
        
        [_startGameTips setHidden:YES];

        [self showWaitingResultActions:^{
                [_waitingResultTips setHidden:YES];
                [self showResultOfMine];
        }];
}


-(PlayerShaiZi*)createNewPlayer:(GamePlayerInfo*)playerInfo{
        
        TablePosition available_pos = [[ShaiZiLogic getInstance] findEmptyTablePosition];
        
        NSString* holder_name = [NSString stringWithFormat:PLAYER_POSITION_HOLDER_NAME, (long)available_pos];
        
        SKNode* empty_node = [self childNodeWithName:holder_name];
        
        PlayerShaiZi* player = [PlayerShaiZi copy:playerInfo from:_playerMySelf withPlaceHolder:empty_node];
        player.playerNode.zPosition = empty_node.zPosition;
        player.tablePosition = available_pos;
        
        [empty_node setHidden:YES];
        player.emptyNode = empty_node;
        
        [self addChild:player.playerNode];
        
        [[ShaiZiLogic getInstance] addPlayer:player];
        
        [self showStartGameButtons];
        
        return player;
}
-(void)updatePlayer:(PlayerShaiZi*)player withNewInfo:(GamePlayerInfo*)playerInfo{
        
        player.nickNameNode.text = playerInfo.nickName;
        
        UIImage* image = [player getScaledImage:playerInfo.imageData];
        SKTexture* avatar_texture = [SKTexture textureWithImage:image];
        player.avatarImageNode = [SKSpriteNode spriteNodeWithTexture:avatar_texture];
}

-(BOOL)isGameRoomIsFull{
        NSLog(@"--->>>当前玩家数量:%lu<<<---",(unsigned long)self.playersInGame.count);
        return  self.playersInGame.count == MAX_PLAYER_IN_THIS_GAME;
}

-(void)updatePlayerInfo:(GamePlayerInfo*)playerInfo forPeerName:(NSString*)peerName{
        
        [super updatePlayerInfo:playerInfo forPeerName:peerName];
        
        PlayerShaiZi* new_player = [self.playersInGame objectForKey:peerName]; 
        if (nil == new_player){
                new_player = [self createNewPlayer:playerInfo];
                [self.playersInGame setObject:new_player forKey:peerName];
        }
        else{
                [self updatePlayer:new_player withNewInfo:playerInfo ];
        }
}


-(void)exitGame{
        dispatch_async(dispatch_get_main_queue(), ^{
                [[ShaiZiLogic getInstance] quitGame];
                _playerMySelf = nil;
                [super exitGame];
        });
}

-(void)removeUser:(MCPeerID *)peerID{
        [super removeUser:peerID];
        
        PlayerShaiZi* player = [self.playersInGame objectForKey:peerID.displayName];
        if (nil == player){
                return;
        }
        
        SKNode* empty_node = player.emptyNode;
        [empty_node setHidden:NO];
        
        [player.playerNode removeFromParent];
        
        [[ShaiZiLogic getInstance] removePlayer:player];
        
        [self.playersInGame removeObjectForKey:peerID.displayName];
}

-(void) finishOneRound:(NSString*)peerName andShowResult:(NSData*)data{
        [super finishOneRound:peerName andShowResult:data];

        NSLog(@"--->>>收到了来自:%@ 的看结果请求,这个是request携带的数据<<<---", peerName);
        
        [_showGameResultButton setHidden:YES];
        [[ShaiZiLogic getInstance] broadCastMyResult];
        [self showWaitingResultActions:^{
                [_waitingResultTips setHidden:YES];
                [self resetGame];
        }];
        [self gameResultData:data forPeer:peerName];
}

-(void)gameResultData:(NSData*)data forPeer:(NSString*)peerName{
        [super gameResultData:data forPeer:peerName];

        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (0 == array.count){
                NSLog(@"--->>>%@没有结果，说明他刚加入--->>>", peerName);
                return;
        }
        PlayerShaiZi* player = [self.playersInGame objectForKey:peerName];
        
        NSLog(@"<<<------我收到的结果:%ld---%@--->>>", (long)player.tablePosition, peerName);
        [[ShaiZiLogic getInstance] setResult:array ForPlayer:player.tablePosition];
        
        SKNode* result_place_holder;
        CGPoint operation = CGPointMake(0, 0);
        switch (player.tablePosition) {
                case TablePositionLEFT:{
                        result_place_holder = [self childNodeWithName:DICE_RESULT_LEFT_PLACE_HOLDER];
                        operation.x = 0;
                        operation.y = 1;
                } break;
                case TablePositionTop:{
                        result_place_holder = [self childNodeWithName:DICE_RESULT_TOP_PLACE_HOLDER];
                        operation.x = 1;
                        operation.y = 0;
                }break;
                case TablePositionRIGHT:{
                        result_place_holder = [self childNodeWithName:DICE_RESULT_RIGHT_PLACE_HOLDER];
                        operation.x = 0;
                        operation.y = 1;
                }break;
                case TablePositionMe:
                default:  return;
        }
        
        
        for (int i = 0; i < DICE_NOMBER_PER_PLAYER; i++){
                NSNumber* dice_value = array[i];
                SKSpriteNode* dice = [self getDiceByValue:[dice_value intValue] withIndex:i byOpertion:operation];
                [result_place_holder addChild:dice];
        }
} 

@end
