//
//  ZXTransferHistoryCell.h
//  ZX
//
//  Created by 许李超 on 17/8/1.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransPortRecord.h"
@interface ZXTransferHistoryCell : UITableViewCell
-(void)renderByRecord:(TransPortRecord*)record;
@end
