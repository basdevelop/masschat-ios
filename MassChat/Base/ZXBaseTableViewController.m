//
//  ZXBaseTableViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/21.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXBaseTableViewController.h"

@interface ZXBaseTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ZXBaseTableViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        
//        self.isInternet = YES;
        self.dataArray = [NSMutableArray array];
        [self.view addSubview:self.tableView];
        [self AFNetworkStatus];
        [self loadNewView];
        [self loadMoreView];
        //        self.navigationController.navigationBar.barTintColor = RGBCOLOR(11, 145, 255);
        
        
}

-(void)loadNewView
{
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        
        // 设置文字
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松开即可刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"加载数据中 ..." forState:MJRefreshStateRefreshing];
        
        // 设置字体
        header.stateLabel.font = [UIFont systemFontOfSize:13];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:13];
        
        // 设置颜色
        header.stateLabel.textColor = [UIColor grayColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
        
        // 设置刷新控件
        self.tableView.mj_header = header;
     
}

-(void)loadMoreView
{
        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        // 设置文字
        [footer setTitle:@"上拉加载更多..." forState:MJRefreshStateIdle];
        [footer setTitle:@"松开加载更多..." forState:MJRefreshStatePulling];
        [footer setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
        
        // 设置字体
        footer.stateLabel.font = [UIFont systemFontOfSize:13];
        
        // 设置颜色
        footer.stateLabel.textColor = [UIColor grayColor];
        
        // 设置footer
        self.tableView.mj_footer = footer;
}

/**
 *  网络监测
 */
-(void)AFNetworkStatus{
        
//        //1.创建网络监测者
//        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
//        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//                if (status == AFNetworkReachabilityStatusUnknown || status ==AFNetworkReachabilityStatusNotReachable) {
//                        self.isInternet = NO;
//                        [self interNetmonitor:YES];
//                }else
//                {       self.isInternet = YES;
//                        [self interNetmonitor:NO];
//                }
//        }] ;
//        [manager startMonitoring];
        [self interNetmonitor:NO];
}

-(void)interNetmonitor:(BOOL)status
{
        
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:0.2];
        //动画的内容
        if (status) {
                self.tableView.y = 35;
        }else{
                self.tableView.y = 0;
        }
        //动画结束
        [UIView commitAnimations];
        self.tableView.mj_footer.hidden = status;
        self.tableView.mj_header.hidden = status;
//        [self setNoInternet:status];
        
        
}

-(void)loadNewData
{
        
}

-(void)loadMoreData
{
        
}
- (UITableView *)tableView {
        if (!_tableView) {
                _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), HEIGHT(self.view ))];
                _tableView.dataSource = self;
                _tableView.delegate = self;
                _tableView.showsHorizontalScrollIndicator = NO;
                _tableView.showsVerticalScrollIndicator = NO;
        }
        return _tableView;
}
- (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return  5;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 50;
}


@end
