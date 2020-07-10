//
//  JoinGameTableViewCell.h
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameListViewController.h"
@interface JoinGameTableViewCell : UITableViewCell
@property(nonatomic, strong)GameListViewController* parentController;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userSignature;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;

- (IBAction)scanCodeToJoinGame:(id)sender;
- (IBAction)createNewGameRoom:(UIButton *)sender;

@end
