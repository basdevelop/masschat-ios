//
//  ZXMineHeaderCell.h
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXUser;
@interface ZXMineHeaderCell : UITableViewCell
@property(nonatomic, weak)UIViewController* parentController;
-(void)cellWithUser:(ZXUser *)user;

- (IBAction)showSettingScene:(id)sender;

@end
