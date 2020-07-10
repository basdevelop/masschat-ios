//
//  FJPullTableView.m
//  BlockTest
//
//  Created by fengjia on 6/4/13.
//  Copyright (c) 2013 fengjia. All rights reserved.
//

#import "FJPullTableView.h"

#define PULL_LOAD_MORE    @"上拉加载更多"
#define PULL_TO_LOAD      @"松开即可加载"
#define PULL_LOADING      @"加载中..."

#define PULL_REFRESH      @"下拉刷新"
#define PULL_TO_REFRESH   @"松开即可刷新"
#define PULL_REFRESHING   @"刷新中..."

@interface FJPullTableView () {
    BOOL isLoading;
    //显示下拉刷新或者上拉加载更多
    UILabel *lbLoadMore;
    UILabel *lbRefresh;
    //标记是否已经创建了uilable显示信息
    BOOL hasLoadMore;
    BOOL hasLoadRefresh;
    //设置是否要进行下拉刷新或上拉加载
    BOOL isShowLoadMore;
    BOOL isShowRefresh;
    //设置执行刷新或加载时菊花效果
    UIActivityIndicatorView *headerIndicator;
    UIActivityIndicatorView *footIndicator;
    //判断是否要进行刷新和加载操作
    BOOL isToRefresh;
    BOOL isToLoadMore;
}
@end


@implementation FJPullTableView
@synthesize pullDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isShowLoadMore = NO;
        isShowRefresh = NO;
    }
    return self;
}

//设置tableview是否显示上拉刷新提示
- (void)setIsShowLoadMore:(BOOL)isNeedToDisplay {
    isShowLoadMore = isNeedToDisplay;
}
- (void)setIsShowRefresh:(BOOL)isNeedToDisplay {
    isShowRefresh = isNeedToDisplay;
}

//当tableview向上滚动时调用此方法
- (void)fjPullScrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isLoading) {
        if (isShowRefresh && scrollView.contentOffset.y <= 0) { //下拉刷新执行
            isToLoadMore = NO;
            if (scrollView.contentOffset.y < -50) {
                if (_isNotShowText) {
                    lbRefresh.text = nil;
                }else{
                    lbRefresh.text = PULL_TO_REFRESH;
                }
                
                isToRefresh = YES;
            } else {
                if (!lbRefresh) {
                    lbRefresh = [[UILabel alloc] initWithFrame:CGRectZero];
                    lbRefresh.backgroundColor = [UIColor clearColor];
                    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0) {
                        lbRefresh.textAlignment = NSTextAlignmentCenter;
                    } else {
                        lbRefresh.textAlignment = NSTextAlignmentCenter;
                    }
                    lbRefresh.font = [UIFont systemFontOfSize:12];
                    lbRefresh.textColor = [UIColor grayColor];
                }
                if (!hasLoadRefresh) {
                    lbRefresh.frame = CGRectMake(0, -40, self.frame.size.width, 40);
                    [self addSubview:lbRefresh];
                    hasLoadRefresh = YES;
                }
                if (_isNotShowText) {
                    lbRefresh.text = nil;
                }else{
                   lbRefresh.text = PULL_REFRESH;
                }
                
                isToRefresh = NO;
            }
        }
        if (isShowLoadMore && scrollView.contentOffset.y >= scrollView.frame.size.height) {//加载更多执行
            isToRefresh = NO;
            if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 60) {
                lbLoadMore.text = PULL_TO_LOAD;
                isToLoadMore = YES;
            } else {
                if (!lbLoadMore) {
                    lbLoadMore = [[UILabel alloc] initWithFrame:CGRectZero];
                    lbLoadMore.backgroundColor = [UIColor clearColor];
                    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0) {
                        lbLoadMore.textAlignment = NSTextAlignmentCenter;
                    } else {
                        lbLoadMore.textAlignment = NSTextAlignmentCenter;
                    }
                    lbLoadMore.font = [UIFont systemFontOfSize:12];
                    lbLoadMore.textColor = [UIColor grayColor];
                }
                if (!hasLoadMore) {
                    lbLoadMore.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, 30);
                    [self addSubview:lbLoadMore];
                    hasLoadMore = YES;
                }
                lbLoadMore.text = PULL_LOAD_MORE;
                isToLoadMore = NO;
            }
        }
    }
}

//当tableview结束拖拽时调用此方法
- (void)fjPullScrollViewDidEndDragging:(UIScrollView *)scrollView {
    if (!isLoading) {
        if (isShowRefresh && isToRefresh) {
            if ([pullDelegate respondsToSelector:@selector(beginToRefreshData:)]) {
                isLoading = YES;
                isToRefresh = NO;
                [self showHeaderIndicatorView];
                [UIView animateWithDuration:0.2 animations:^{
                    self.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
                } completion:^(BOOL finished) {
                    
                }];
                
                [pullDelegate beginToRefreshData:self];
            }
        }
        if (isShowLoadMore && isToLoadMore) {
            if ([pullDelegate respondsToSelector:@selector(beginToLoadMoreData:)]) {
                isLoading = YES;
                isToLoadMore = NO;
                [self showFootIndicatorView];
                [UIView animateWithDuration:0.2 animations:^{
                    self.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
                } completion:^(BOOL finished) {
                    
                }];
                [pullDelegate beginToLoadMoreData:self];
            }
        }
    }
}

//加载数据结束时执行此操作
- (void)fjPullScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView isRefresh:(BOOL)refresh{
    
    [self reloadData];
    if (refresh) {
//        if (isShowRefresh) {
            NSLog(@"刷新结束");
            [UIView animateWithDuration:0.2 animations:^{
                self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            } completion:^(BOOL finished) {
                [self hideHeaderIndicatorView];
                isLoading = NO;
            }];
//        }
    } else {
//        if (isShowLoadMore) {
            NSLog(@"加载结束");
            [UIView animateWithDuration:0.2 animations:^{
                self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            } completion:^(BOOL finished) {
                [self hideFootIndicatorView];
                isLoading = NO;
            }];
//        }
    }
}


#pragma mark - Helper

- (void)showHeaderIndicatorView {
    if (!headerIndicator) {
        headerIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (_isNotShowText) {
          headerIndicator.frame = CGRectMake(self.frame.size.width/2 - 10, 10, 20, 20);
            lbRefresh.text = nil;
        }else{
          headerIndicator.frame = CGRectMake(self.frame.size.width/2 - 50, 10, 20, 20);
            lbRefresh.text = PULL_REFRESHING;
        }
        
    }
    [headerIndicator startAnimating];
    
    [lbRefresh addSubview:headerIndicator];
}

- (void)hideHeaderIndicatorView {
    if (headerIndicator) {
        [headerIndicator stopAnimating];
        [headerIndicator removeFromSuperview];
    }
    [lbRefresh removeFromSuperview];
    hasLoadRefresh = NO;
}

- (void)showFootIndicatorView {
    if (!footIndicator) {
        footIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        footIndicator.frame = CGRectMake(self.frame.size.width/2 - 50, 5, 20, 20);
    }
    [footIndicator startAnimating];
    lbLoadMore.text = PULL_LOADING;
    [lbLoadMore addSubview:footIndicator];
}

- (void)hideFootIndicatorView {
    if (footIndicator) {
        [footIndicator stopAnimating];
        [footIndicator removeFromSuperview];
    }
    [lbLoadMore removeFromSuperview];
    hasLoadMore = NO;
}

@end
