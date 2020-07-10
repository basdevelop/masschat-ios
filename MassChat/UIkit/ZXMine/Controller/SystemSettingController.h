//
//  SystemSettingController.h
//  MassChat
//
//  Created by wsli on 2017/9/8.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemSettingController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *messageSoundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *openBusinessInfoSwitch;

- (IBAction)changeMessageSounds:(UISwitch*)sender;
- (IBAction)changeBusinessInfo:(UISwitch*)sender;
@property (weak, nonatomic) IBOutlet UISwitch *messageNotifierSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *changeBusinessInfoSwitch;


@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UITextView *signature;

@end
