//
//  ZXNoneFileCell.m
//  ZX
//
//  Created by 许李超 on 17/7/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXNoneFileCell.h"

@interface ZXNoneFileCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;


@end

@implementation ZXNoneFileCell

- (void)awakeFromNib {
        [super awakeFromNib];
        ViewRadius(_bgView, 3);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
