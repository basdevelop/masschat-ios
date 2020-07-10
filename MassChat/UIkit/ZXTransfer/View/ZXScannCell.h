//
//  ZXScannCell.h
//  ZX
//
//  Created by 许李超 on 17/7/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransportTask.h"

typedef void(^ScannBlock)(void);

@interface ZXScannCell : UITableViewCell

-(void)cellWithSegmentType:(NSInteger)type withParentCtl:(UIViewController*)parentController;
@end
