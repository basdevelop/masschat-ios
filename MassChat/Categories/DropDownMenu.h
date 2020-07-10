//
//  DropDownMenu.h
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedAtIndex)(NSInteger index);

@interface DropDownMenu : UIView

@property (copy, nonatomic) SelectedAtIndex selectedAtIndex;
- (void)selectedAtIndex:(SelectedAtIndex)block;

- (instancetype)initWithWidth:(CGFloat)width images:(NSArray *)images titles:(NSArray *)titles;

- (void)showMenu;

@end
