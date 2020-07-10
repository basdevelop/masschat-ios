#import "TransPortRecord.h"
#import "ZXTransferHistoryViewController.h"
#import "ZXTransferHistoryCell.h"
#import "DataBaseManager.h"

@interface ZXTransferHistoryViewController (){
        NSMutableArray*         _recordHistory;
        NSInteger               _lastRecordIdToShow;
}

@end

@implementation ZXTransferHistoryViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        
        _lastRecordIdToShow = LONG_MAX;
        
        _recordHistory = [[DataBaseManager getInstance] loadTransRecord:&(_lastRecordIdToShow)];
        
        self.navigationItem.title = @"历史";
        
        self.tableView.height = self.tableView.height - TabBarHeight;
        self.tableView.backgroundColor = RGBCOLOR(255, 255, 255);
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXTransferHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HistoryCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        
        return _recordHistory.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

        return 145.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
        static NSString *identify = @"HistoryCell";
        ZXTransferHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        TransPortRecord* record = [_recordHistory objectAtIndex:indexPath.row];
        [cell renderByRecord:record];
        return cell;
        
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
        return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
        
        TransPortRecord* record = [_recordHistory objectAtIndex:indexPath.row];
        
        [[DataBaseManager getInstance] removeTransRecord:[record recordId]];
        
        [_recordHistory removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}



#pragma mark - 刷新、加载
-(void)loadNewData{
        [self.tableView.mj_header endRefreshing];
        NSMutableArray* new_array = [[DataBaseManager getInstance] loadTransRecord:&(_lastRecordIdToShow)];
        if (nil == new_array){ dispatch_async(dispatch_get_main_queue(), ^{
                [[JCCUtils sharedInstance] showProgressHud:self.view withMessage:@"没有更多数据"];});
        }else{
                [_recordHistory addObjectsFromArray:new_array];
        }
}

-(void)loadMoreData{
        [self.tableView.mj_footer endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
