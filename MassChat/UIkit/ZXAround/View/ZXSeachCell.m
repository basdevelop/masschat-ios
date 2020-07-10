//
//  ZXSeachCell.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXSeachCell.h"

@interface ZXSeachCell()

@property (weak, nonatomic) IBOutlet UISearchBar *seachBar;


@end

@implementation ZXSeachCell

- (void)awakeFromNib {
        [super awakeFromNib];
        [_seachBar.layer setBorderColor:[UIColor whiteColor].CGColor];
        _seachBar.layer.cornerRadius = 14 ;
        _seachBar.layer.masksToBounds = YES;
        [_seachBar.layer setBorderWidth:8];
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
