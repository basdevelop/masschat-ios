#import "ZXChatViewController.h"
#import "MessageBean.h"
#import "MessageManager.h"
#import "DataBaseManager.h"
#import "ZXUser.h"
#import "JCCUtils.h"


@interface ZXChatViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, UINavigationControllerDelegate, WifiDirectSessionDelegate, MessageManagerDelegate>{
        
        NSInteger       _lastMessageIdToShow;
        UIBarButtonItem* _rightBtn;
        ZXUser*         _currentUser;
}

@property (nonatomic,strong) UIImage *willSendImage;
@property (strong, nonatomic) MCPeerID *friendPeerId;
@property (strong, nonatomic) FriendNearBy *currentFriendBean;
@end

@implementation ZXChatViewController

-(id)initWithFriend:(FriendNearBy*)friendBean{
        self = [super init];
        if(self){
                self.friendPeerId = friendBean.peerId;
                self.currentFriendBean = friendBean;
                _currentUser = [ZXUser loadSelfProfile];
        }
        return self;
}

- (void)viewDidLoad {
        [super viewDidLoad];

        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_ic"]style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];

        [leftButton setTintColor:RGBCOLOR(245, 245, 245)];
        self.navigationItem.leftBarButtonItem = leftButton;
        self.delegate = self;
        self.dataSource = self;
        
        _lastMessageIdToShow = LONG_MAX;
        self.mMsgList = [[DataBaseManager getInstance] loadHistoryMessages:self.friendPeerId.displayName
                                                        withLastId:&_lastMessageIdToShow];
        
        [self finishSend];
        
        _rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"未连接"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(reconnectThisPeer)];
       
        self.navigationItem.rightBarButtonItem = _rightBtn; 
}

-(void)reconnectThisPeer{
        if (!_rightBtn.tag){
                [[WifiDirectManager getInstance] inviteThisFriend:self.friendPeerId];
        }
}
-(void)viewDidAppear:(BOOL)animated{
        [super viewDidAppear:animated];
        
        FriendNearBy *friend_bean = [[WifiDirectManager getInstance]
                                    getFriendByPeerId:self.friendPeerId];
        
        friend_bean.unreadMessage = 0;
        self.title = friend_bean.name;
        
        if (friend_bean.connectStatus != MCSessionStateConnected){
                [[WifiDirectManager getInstance] inviteThisFriend:self.friendPeerId];
                _rightBtn.tag = NO;
        }else{
                 _rightBtn.tag = YES;
                [_rightBtn setTitle:@"已连接"];
        }
        
        [[WifiDirectManager getInstance] setSessionDelegate:self];
        [[MessageManager getInstance] registerDelegate:self withPeerName:self.friendPeerId.displayName];
        
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(reconnectThisPeer)
                                                    name:@"applicationDidBecomeActive" object:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"applicationDidBecomeActive" object:nil];
        
        [super viewDidDisappear:animated];
        [[WifiDirectManager getInstance] setSessionDelegate:nil];
        [[MessageManager getInstance] unregisterDelegateByPeerName:self.friendPeerId.displayName];
}


#pragma mark - 发送消息、接受到新消息

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text {
        if (text.length == 0){
                return;
        }
        
        if (NO == _rightBtn.tag){
                MessageBean* msg_bean = [MessageBean new];
                [msg_bean setTime:[NSDate date]];
                [msg_bean setText:@"对方已经离线，请稍后再试"];
                [msg_bean setType:MessageBeanTypeChatMsg];
                [msg_bean setInMsg:YES];
                
                [self.mMsgList addObject:msg_bean];
                [self finishSend];
                return;
        }
        
        MessageBean* msg_bean = [MessageBean new];
        [msg_bean setTime:[NSDate date]];
        [msg_bean setText:text];
        [msg_bean setType:MessageBeanTypeChatMsg];
        [msg_bean setInMsg:NO];
        
        [self.mMsgList addObject:msg_bean];
        [JSMessageSoundEffect playMessageSentSound];
        
        Boolean success = [[MessageManager getInstance] sendMessage:msg_bean withPeerName:self.friendPeerId.displayName];
        [msg_bean setStatus:success];
        
        [self finishSend];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.mMsgList.count;
}
//点击cell跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        [self.chatKeyBoard keyboardDown];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Messages view delegate
- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
        MessageBean* msg_bean = [self.mMsgList objectAtIndex:indexPath.row];
        return msg_bean.inMsg ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

-(NSMutableArray*)messageArrayWithData{
        return self.mMsgList;
}

#pragma mark - 聊天框样式
- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
        return JSBubbleMessageStyleSquare;
}

-(BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.row == 0) {
                return YES;
        }
    
        MessageBean* msg_bean = self.mMsgList[indexPath.row - 1];
        NSInteger lastMessageSendTime = [msg_bean.time timeIntervalSince1970];

        msg_bean = self.mMsgList[indexPath.row];
        NSInteger nowMessageSendTime = [msg_bean.time timeIntervalSince1970];
    
        if (nowMessageSendTime - lastMessageSendTime > 120) {
                return YES;
        }
        return NO;
        
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
        return JSBubbleMediaTypeText;
}


- (JSMessagesViewTimestampPolicy)timestampPolicy {
        return JSMessagesViewTimestampPolicyCustom;
}


- (JSMessagesViewAvatarPolicy)avatarPolicy  {
        return JSMessagesViewAvatarPolicyBoth;
}



- (JSAvatarStyle)avatarStyle {
        return JSAvatarStyleCircle;
}

#pragma mark - 设置发送类型

- (JSInputBarStyle)inputBarStyle {
        return JSInputBarStyleDefault;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
        [self.view endEditing:YES];
}

- (void)endEdit{
        [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        
        if ([touch.view isKindOfClass:[UITableViewCell class]]){
                
                return NO;
        }
        
        return YES;
        
}

#pragma mark - Messages view data source

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        MessageBean* msg_bean = [self.mMsgList objectAtIndex:indexPath.row];
        if(msg_bean){
                return msg_bean.text;
        }
        return nil;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath{
        
        MessageBean* msg_bean = self.mMsgList[indexPath.row];
        return msg_bean.time;
}

#pragma mark - 聊天头像
- (UIImage *)avatarImageForIncomingMessage{
       
        if (self.currentFriendBean.avatar == nil){
                return [UIImage imageNamed:@"head_img"];
        }else {
                return self.currentFriendBean.avatar;
        }
}


- (UIImage *)avatarImageForOutgoingMessage{
        
        if (_currentUser.avatar == nil){
                return [UIImage imageNamed:@"head_img"];
        }else {
                return _currentUser.avatar;
        }
}


- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
        return nil;
}
- (void)beginToRefreshData:(FJPullTableView *)tableView {//模拟刷新操作
        dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray* more_data = [[DataBaseManager getInstance] loadHistoryMessages:self.friendPeerId.displayName
                                                                                    withLastId:&_lastMessageIdToShow];
                if (more_data.count == 0){
                        [self.tableView setIsShowRefresh:NO];
                        [self.tableView fjPullScrollViewDataSourceDidFinishedLoading:self.tableView isRefresh:NO];
                }else{
                        for (int i = (int)more_data.count - 1; i >= 0; i--){
                                
                                 [self.mMsgList insertObject:[more_data objectAtIndex:i] atIndex:0];
                        
                        }
                }
                [self.tableView fjPullScrollViewDataSourceDidFinishedLoading:self.tableView isRefresh:NO];
                [self.tableView reloadData];
        });
}


-(void)backHome{
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WifiDirectSessionDelegate
- (void)didConnectedBySession:(MCSession*)session{        
        dispatch_async(dispatch_get_main_queue(), ^{
                _rightBtn.tag = YES;
                [_rightBtn setTitle:@"已连接"];
        });
}

- (void)hasDisConnectedBySession{
        dispatch_async(dispatch_get_main_queue(), ^{
                _rightBtn.tag = NO;
                [_rightBtn setTitle:@"未连接"];
        });
}


#pragma mark -MessageManagerDelegate
- (void)didReceivedMessage:(MessageBean*)msg{
        
        [self.mMsgList addObject:msg];
        
        [JSMessageSoundEffect playMessageReceivedSound];
        
        [self finishSend];
}

@end
