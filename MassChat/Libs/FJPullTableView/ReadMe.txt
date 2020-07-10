1. 使用方法： 
（1）导入     #import "FJPullTableView.h"
（2）使用    绑定代理FJPullTableViewDelegate, UISCrollViewDelegate
定义变量  FJPullTableView *mytv;

    mytv = [[FJPullTableView alloc] initWithFrame:CGRectMake(10, 50, 200, 200)];
    mytv.delegate = self;
    mytv.dataSource = self;
    mytv.pullDelegate = self;
    [mytv setIsShowLoadMore:YES];
    [mytv setIsShowRefresh:YES];
    [self.view addSubview: mytv];
实现代理方法
//UIScrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [mytv fjPullScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [mytv fjPullScrollViewDidEndDragging:scrollView];
}

//FJPullDelegate
- (void)beginToRefreshData:(FJPullTableView *)tableView {//模拟刷新操作
    [self performSelectorInBackground:@selector(refresh) withObject:nil];
}
- (void)beginToLoadMoreData:(FJPullTableView *)tableView {//模拟加载更多操作
    [self performSelectorInBackground:@selector(load) withObject:nil];
}
//模拟操作的方法
- (void)refresh {
    NSLog(@"正在刷新");
    sleep(2);
    ...
    [self performSelectorOnMainThread:@selector(refreshDone) withObject:nil waitUntilDone:NO];
}
- (void)refreshDone {
    //刷新完执行的操作，必须调用
    [ctv fjPullScrollViewDataSourceDidFinishedLoading:ctv isRefresh:YES];
    
}
- (void)load {
    NSLog(@"正在加载");
    sleep(2);
    ...
    [self performSelectorOnMainThread:@selector(loadDone) withObject:nil waitUntilDone:NO];
}
- (void)loadDone {
    //加载完执行的操作，必须实现
    [ctv fjPullScrollViewDataSourceDidFinishedLoading:ctv isRefresh:NO];
}

注意：  加载更多执行完后
1. 刷新、加载操作完成后必须调用方法, 不管操作成功还是失败
[mytv fjPullScrollViewDataSourceDidFinishedLoading:mytv isRefresh:YES];
或 
[mytv fjPullScrollViewDataSourceDidFinishedLoading:mytv isRefresh:YES];
2. 设置是否刷新和加载的方法，尤其是加载更多根据具体逻辑设置时候继续需要加载更多
[mytv setIsShowLoadMore:YES];
[mytv setIsShowRefresh:YES];

