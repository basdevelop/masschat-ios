#import "ZXMineViewController.h"
#import "ZXMineHeaderCell.h"
#import "ZXMineSelectCell.h"
#import "ZXUser.h"
#import "WXApi.h"
#import "MusicPlayerController.h"
#import "WifiDirectManager.h"
#import "BusinessInfoController.h"
#import "HelpViewController.h"

@interface ZXMineViewController ()
@property (nonatomic, strong) ZXUser    *user;

@end

@implementation ZXMineViewController

- (void)viewDidLoad {
        [super viewDidLoad];
        self.navigationItem.title = @"我的";
        _user = [ZXUser loadSelfProfile];
        self.hiddenBackBtn = YES;
        self.tableView.scrollEnabled = NO;
        self.tableView.mj_header = nil;
        self.tableView.backgroundColor = RGBCOLOR(240, 240, 240);
        
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXMineHeaderCell"
                                                   bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HeaderCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"ZXMineSelectCell"
                                                   bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SelectCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CooperationView"
                                                   bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CooperationViewCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinUpdate) name:@"has_change_profile_by_wexin" object:nil];
}

-(void)weixinUpdate{
        _user = [ZXUser loadSelfProfile];
        [self.tableView reloadData];
//        [[WifiDirectManager getInstance] restartShowMySelf];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
        return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        if (section == 0 ||section == 1) {
                return 0.f;
        }else if (section == 2 ||section == 3) {
                return 10.f;
        }
        return 10.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (section == 0 || section == 1|| section == 3){
                return 1;
        }else if (section == 2){
                return 3;
        }
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section  == 0) {
                return 155.f;
        }else if (indexPath.section == 3){
                return 200.f;
        }
        return 45.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.section == 0) {
                static NSString *identify = @"HeaderCell";
                ZXMineHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell cellWithUser:_user];
                cell.tag = 1;
                cell.parentController = self;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
        }
        else if (indexPath.section == 3){
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CooperationViewCell" forIndexPath:indexPath];
                cell.tag = 3;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
        }else if (indexPath.section == 1 || indexPath.section == 2){
                static NSString *identify = @"SelectCell";
                ZXMineSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
                [cell cellWithIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                return cell;
        }
        
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
        if (indexPath.section != 1 && indexPath.section != 2){
                return;
        }
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        switch (cell.tag) {
                        
                case 21:{
                        SendAuthReq* req =[SendAuthReq new];
                        req.scope = @"snsapi_userinfo" ;
                        req.state = @"123" ;
                        [WXApi sendReq:req];
                        
                }break;
                        
                case 10:{
                        MusicPlayerController *musicVC = [MusicPlayerController new];
                        musicVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:musicVC animated:YES];
                }break;
                case 20:{
                        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        BusinessInfoController *business_info = [storyboard instantiateViewControllerWithIdentifier:@"BusinessInfoVC"];
                        business_info.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:business_info animated:YES];
                }break;
                case 22:{
                        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        HelpViewController *help_view = [storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
                        help_view.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:help_view animated:YES];
                }break;
                        
                default:
                        break;
        }
}

-(void)shareThisApp{
        
        WXMediaMessage* message = [WXMediaMessage message];
        message.title = @"神奇的APP";
        message.description = @"无需网络仍可聊天传文件，长途旅行必备神器.";
        UIImage* image = [UIImage imageNamed:@"zhongxin_logo_ic"];
        [message setThumbImage:image];
        
        WXWebpageObject* webpage_obj = [WXWebpageObject object];
        webpage_obj.webpageUrl = @"https://itunes.apple.com/us/app/%E4%BC%97%E8%AE%AF/id1239672957?l=zh&ls=1&mt=8";
        message.mediaObject = webpage_obj;
        
        SendMessageToWXReq* req = [SendMessageToWXReq new];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
}

@end
