#import "ZXAroundFriendViewController.h"
#import "ZXChatViewController.h"
#import "ZXSeachCell.h"
#import "ZXChatCell.h"
#import "DropDownMenu.h"
#import "WifiDirectManager.h"

@interface ZXAroundFriendViewController ()<WifiDirectPeerDelegate>
{
        DropDownMenu *_dropDownMenu;
        
        NSArray *_titles;
}


@end

@implementation ZXAroundFriendViewController

- (void)viewDidLoad {
	[super viewDidLoad];
        self.navigationItem.title = @"周围";
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:mImageByName(@"more_ic") style:UIBarButtonItemStylePlain target:self action:@selector(showListView)];
        
        [rightButton setTintColor:RGBCOLOR(255, 255, 255)];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        _titles = @[@"个人设置"];
        
        self.hiddenBackBtn = YES;
        self.tableView.height = self.tableView.height - TabBarHeight;
        self.tableView.backgroundColor = RGBCOLOR(245, 245, 245);
//        [self fetchBills:YES];
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXSeachCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SeachCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXChatCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChatCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [[WifiDirectManager getInstance] startShowMyself];
        
        [[WifiDirectManager getInstance] findNearByFriends];
        
        
}

-(void) viewDidAppear:(BOOL)animated{
        [super viewDidAppear:animated];
        
        [[WifiDirectManager getInstance] setPeerDelegate:self];
        [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
        [super viewDidDisappear:animated];
        [[WifiDirectManager getInstance] setPeerDelegate:nil];
}


#pragma mark - 个人设置
-(void)showListView{
        if (!_dropDownMenu) {
                CGFloat with = (kscreenWidth  - 20)/2;
              _dropDownMenu = [[DropDownMenu alloc] initWithWidth: with images:nil titles:_titles];
        }
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        [_dropDownMenu selectedAtIndex:^(NSInteger index) {
                 [[JCCUtils sharedInstance] showProgressHudAndHideDelay:1 inView:self.view withMessage:@"个人设置"];
        }];
        [_dropDownMenu showMenu];
        
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (section == 0) {
                return 1;
        }
        NSArray* deivce_list = [[WifiDirectManager getInstance] getPeerDeviceList];
        return [deivce_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section  == 0) {
                return 50.f;
        } 
        return KEdqCellHeight(70);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
                static NSString *identify = @"SeachCell";
                ZXSeachCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
        }
        
        static NSString *identify = @"ChatCell";
        ZXChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSArray* deivce_list = [[WifiDirectManager getInstance] getPeerDeviceList];
        FriendNearBy* friend_bean = [deivce_list objectAtIndex:indexPath.row];
        
        [cell renderContent:friend_bean];
        return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.section == 0) {
                return;
        }
 
        NSArray* deivce_list = [[WifiDirectManager getInstance] getPeerDeviceList];
        FriendNearBy* friend_bean = [deivce_list objectAtIndex:indexPath.row];
        
        ZXChatViewController *chatVC = [[ZXChatViewController alloc]
                                        initWithFriend:friend_bean];
        chatVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatVC animated:YES];
} 

#pragma mark - 刷新、加载
-(void)loadNewData
{dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];});
}

-(void)loadMoreData{dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_footer endRefreshing];});
}


#pragma mark - 设备状体变更
- (void)friendStateChanges{
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
        });
}
@end
