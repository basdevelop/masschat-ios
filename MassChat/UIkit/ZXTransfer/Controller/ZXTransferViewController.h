//
//  ZXTransferViewController.h
//  ZX
//
//  Created by 许李超 on 17/7/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseTableViewController.h"
#import "SGQRCodeScanningVC.h"
#import "TransportTask.h"

@interface ZXTransferViewController : ZXBaseTableViewController <SGQRCodeScanningDelegate, TransportTaskDelegate>

@end
