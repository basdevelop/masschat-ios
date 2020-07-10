//
//  FJPullTableView.h
//  BlockTest
//
//  Created by fengjia on 6/4/13.
//  Copyright (c) 2013 fengjia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FJPullTableView;
@protocol FJPullTableViewDelegate <NSObject>
//程序中加载数据的代码在此方法中执行
@optional
- (void)beginToLoadMoreData:(FJPullTableView *)tableView;
- (void)beginToRefreshData:(FJPullTableView *)tableView;
@end

@interface FJPullTableView : UITableView <UIScrollViewDelegate>
@property BOOL isNotShowText;
@property (nonatomic, assign) id<FJPullTableViewDelegate> pullDelegate;
//该方法控制tableview是否显示上拉刷新提示，是否执行上拉刷新操作
- (void)setIsShowLoadMore:(BOOL)isNeedToDisplay;
- (void)setIsShowRefresh:(BOOL)isNeedToDisplay;

- (void)fjPullScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fjPullScrollViewDidEndDragging:(UIScrollView *)scrollView;

//更多数据加载完成后需要调用此方法
- (void)fjPullScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView isRefresh:(BOOL)refresh;
@end
