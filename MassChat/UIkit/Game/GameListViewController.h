//
//  GameListViewController.h
//  MassChat
//
//  Created by wsli on 2017/9/12.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseTableViewController.h"
#import "GameServiceInfoBean.h"
#import "SGQRCodeScanningVC.h"

@interface GameListViewController : ZXBaseTableViewController <SGQRCodeScanningDelegate>


-(void)joinTheGame:(GameServiceInfoBean*)gameRoomInfo;

@end
