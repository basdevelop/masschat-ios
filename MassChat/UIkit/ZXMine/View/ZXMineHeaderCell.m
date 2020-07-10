//
//  ZXMineHeaderCell.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXMineHeaderCell.h"
#import "ZXUser.h"
#import "SystemSettingController.h"
#import "JCCUtils.h"

@interface ZXMineHeaderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nickName; 
@property (weak, nonatomic) IBOutlet UILabel *signature;

@end


@implementation ZXMineHeaderCell

- (void)awakeFromNib {
        [super awakeFromNib];
         self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_bg"]];
}

- (IBAction)showSettingScene:(id)sender {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SystemSettingController *systemVC = [storyboard instantiateViewControllerWithIdentifier:@"SystemSettingVC"];
        systemVC.hidesBottomBarWhenPushed = YES;
        [self.parentController.navigationController pushViewController:systemVC animated:YES];
}

-(void)cellWithUser:(ZXUser *)user{
        _image.image = user.avatar == nil ? [UIImage imageNamed:@"head_img"]: user.avatar;
        _nickName.text =  [[[NSURL fileURLWithPath:user.nickName] lastPathComponent] stringByRemovingPercentEncoding]; 
        _signature.text = user.signature == nil?@"不一样的烟火":user.signature;
        [[JCCUtils sharedInstance] graphicsImage:_image];
} 

@end
