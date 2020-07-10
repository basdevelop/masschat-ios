//
//  ZXTransferViewController.m
//  ZX
//
//  Created by 许李超 on 17/7/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXTransferViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SGQRCode.h"
#import "SGQRCodeScanningVC.h"
#import "HMSegmentedControl.h"
#import "ZXTransferHistoryViewController.h"
#import "ZXScannCell.h"
#import "ZXNoneFileCell.h"
#import "ZXChatCell.h"
#import "ZXSeachCell.h"
#import "ZXTransmittingCell.h"
#import "ZXTransDoneCell.h"
#import "FileTransferManager.h"



@interface ZXTransferViewController ()<UIScrollViewDelegate,
UITableViewDataSource,UITableViewDelegate>{
        NSArray*        _sendingTaskQueue;
        BOOL            _hasSendingTask;
        NSInteger       _currentWorkingPage;
        NSArray*        _receivingTaskQueue;
        BOOL            _hasReceivingTask;}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic,strong) UITableView *sendFileTableView;
@end

@implementation ZXTransferViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        self.hiddenBackBtn = YES;
        UIBarButtonItem *right_button = [[UIBarButtonItem alloc] initWithTitle:@"文件历史" style:UIBarButtonItemStylePlain target:self action:@selector(transferHistory)];
        NSDictionary *attributes=[NSDictionary  dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:14], NSFontAttributeName, nil];
        [right_button setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [right_button setTintColor:RGBCOLOR(245, 245, 245)];
        
        self.navigationItem.rightBarButtonItem= right_button;         
        
        [self settingScrollView];
        [self settingSegment];
        
        _sendingTaskQueue = [NSArray new];
        _receivingTaskQueue = [NSArray new];
        _hasSendingTask = NO;
        _hasReceivingTask = NO;
        _currentWorkingPage = 0;
}

-(void)transferHistory{
        
        ZXTransferHistoryViewController * historyVC = [ZXTransferHistoryViewController new];
        historyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:historyVC animated:YES];
}

-(void)settingScrollView
{
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kscreenWidth, kscreenHeight)];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = CGSizeMake(kscreenWidth * 2, kscreenHeight);
        self.scrollView.delegate = self;
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, kscreenWidth, kscreenHeight) animated:NO];
        [self.view addSubview:self.scrollView];
        [self.scrollView addSubview:self.tableView];
        [self.scrollView addSubview:self.sendFileTableView];
        self.tableView.height = self.tableView.height - TabBarHeight;
        
        //        self.sendFileTableView.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.sendFileTableView registerNib:[UINib nibWithNibName:@"ZXScannCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXScannCell"];
        [self.sendFileTableView registerNib:[UINib nibWithNibName:@"ZXNoneFileCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXNoneFileCell"];
        [self.sendFileTableView registerNib:[UINib nibWithNibName:@"ZXTransDoneCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXTransDoneCell"];
        
        [self.sendFileTableView registerNib:[UINib nibWithNibName:@"ZXTransmittingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXTransmittingCell"];
        
        self.sendFileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //        self.tableView.backgroundColor = RGBCOLOR(245, 245, 245);
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXScannCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXScannCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXNoneFileCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXNoneFileCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXTransDoneCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXTransDoneCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXTransmittingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZXTransmittingCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (UITableView *)sendFileTableView {
        if (!_sendFileTableView) {
                _sendFileTableView = [[UITableView alloc] initWithFrame:CGRectMake(kscreenWidth, 0, WIDTH(self.view), HEIGHT(self.view ))];
                _sendFileTableView.height = self.sendFileTableView.height - 120;
                _sendFileTableView.dataSource = self;
                _sendFileTableView.delegate = self;
                _sendFileTableView.showsHorizontalScrollIndicator = NO;
                _sendFileTableView.showsVerticalScrollIndicator = NO;
        }
        return _sendFileTableView;
}

-(void)settingSegment
{
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"收文件", @"发文件"]];
        [self.segmentedControl setFrame:CGRectMake(0, 0, kscreenWidth / 2.5, NavigationBarHeight)];
        __weak __typeof__(self) weakSelf = self;
        [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
                _currentWorkingPage = index;
                if (index == 0) {
                        [weakSelf.scrollView scrollRectToVisible:CGRectMake(0, 0, kscreenWidth, kscreenHeight) animated:NO];
                        [weakSelf.tableView reloadData];
                }else{
                        [weakSelf.scrollView scrollRectToVisible:CGRectMake(kscreenWidth, 0, kscreenWidth, kscreenHeight) animated:NO];
                        [weakSelf.sendFileTableView reloadData];
                }
        }];
        
        self.segmentedControl.selectionIndicatorHeight = 3.0f;
        self.segmentedControl.backgroundColor = [UIColor clearColor];
        self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : RGBCOLOR(235, 235, 235)};
        self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
        self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.navigationItem.titleView = self.segmentedControl;
}


- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        _currentWorkingPage = page;
        
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
        if (0 == page){
                [self.tableView reloadData];
        }else{
                [self.sendFileTableView reloadData];
        }
}

- (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (section == 1) {
                if (_currentWorkingPage == 0){
                        return _hasReceivingTask ? 0 : 1;
                }else{
                        return _hasSendingTask ? 0 : 1;
                }
        }else if (section == 2){
                if (_currentWorkingPage == 0){
                        return _receivingTaskQueue.count;
                }else{
                        return _sendingTaskQueue.count;
                }
        }else{
               return 1;
        }
        
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section == 0) {
                return 350.f;
        }
        if (indexPath.section == 1) {
                return 100.f;
        }
        return 75.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
                
                static NSString *identify = @"ZXScannCell";
                ZXScannCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell cellWithSegmentType:_currentWorkingPage withParentCtl:self];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
                
        }else if (indexPath.section == 1) {
                
                static NSString *identify = @"ZXNoneFileCell";
                ZXNoneFileCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
                
        } else if (indexPath.section == 2) {
                
                static NSString *identify = @"ZXTransmittingCell";
                ZXTransmittingCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                if (_currentWorkingPage == 0){
                        TransportTask* task = [_receivingTaskQueue objectAtIndex:indexPath.row];
                        [cell renderByTaskInfo:task];
                }else{
                        TransportTask* task = [_sendingTaskQueue objectAtIndex:indexPath.row];
                        [cell renderByTaskInfo:task];
                }
                
                return cell;
        }else{
                return nil;
        }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section == 0) {
                return;
        }
}



#pragma mark - 扫码之后回调结果
- (void)getQRStringSuccess:(NSString*) QRString{
        
        [[FileTransferManager getInstance] startLoadFile:QRString withDelegate:self];
}

- (void)getQRStringFailed{
}

#pragma mark - 传输开始之后的代理 TransportTaskDelegate
-(void) didStartSendImage{
        _sendingTaskQueue = [[FileTransferManager getInstance] sendTaskCache].allValues;
        
        _hasSendingTask = _sendingTaskQueue.count > 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.sendFileTableView reloadData];
        });
}

-(void) didFinishedSendImage{
        _sendingTaskQueue = [[FileTransferManager getInstance] sendTaskCache].allValues;
        
        _hasSendingTask = _sendingTaskQueue.count > 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.sendFileTableView reloadData];
        });
}

-(void) didStartReceiveImage{
        
        _receivingTaskQueue =[[FileTransferManager getInstance] receiveTaskCache].allValues;
        
        _hasReceivingTask = _receivingTaskQueue.count > 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
        });
}

-(void)didFinishedReceiveImage:(NSString*) tips{
        
        _receivingTaskQueue =[[FileTransferManager getInstance] receiveTaskCache].allValues;
        
        _hasReceivingTask = _receivingTaskQueue.count > 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData]; 
                UIAlertController* alert_view = [UIAlertController alertControllerWithTitle:@"提示" message:tips preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * action) {
                        [alert_view removeFromParentViewController];
                }];
                
                [alert_view addAction:confirm];
                
                [self presentViewController:alert_view animated:YES completion:nil];
        });
}

@end
