//
//  ZXTransmittingCell.h
//  ZX
//
//  Created by 许李超 on 17/7/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransportTask.h"
@interface ZXTransmittingCell : UITableViewCell

-(void)cellWithTransmit;
-(void)renderByTaskInfo:(TransportTask*)task;
@end
