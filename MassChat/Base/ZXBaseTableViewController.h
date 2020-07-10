//
//  ZXBaseTableViewController.h
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseCommonViewController.h"

@interface ZXBaseTableViewController : ZXBaseCommonViewController
@property(nonatomic,strong)UITableView *tableView;
//@property BOOL isInternet;
@property BOOL isLoad;
@property BOOL isMore;
@property(nonatomic,strong)NSMutableArray *dataArray;//数据源
-(void)loadNewData;
-(void)loadMoreData;
@end
