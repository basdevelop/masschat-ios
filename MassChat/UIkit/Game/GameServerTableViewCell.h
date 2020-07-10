//
//  GameServerTableViewCell.h
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameServiceInfoBean.h"
#import "GameListViewController.h"

@interface GameServerTableViewCell : UITableViewCell

@property (weak, nonatomic) GameListViewController *parentController;

@property (weak, nonatomic) IBOutlet UILabel *serverInstanceName; 

@property (weak, nonatomic) IBOutlet UILabel *playersNoInGame;

- (IBAction)joinThisGame:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *gameDescDetails;
@property (weak, nonatomic) IBOutlet UILabel *gameDescTitle;

-(void)renderContent:(GameServiceInfoBean*)serverBean;

@end
