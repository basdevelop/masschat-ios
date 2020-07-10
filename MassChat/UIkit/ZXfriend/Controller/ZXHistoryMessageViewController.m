//
//  ZXHistoryMessageViewController.m
//  MassChat
//
//  Created by wsli on 2017/8/28.
//  Copyright © 2017年 众信. All rights reserved.
//
#import "MessageBean.h"
#import "DataBaseManager.h"
#import "ZXHistoryMessageViewController.h"

@interface ZXHistoryMessageViewController ()<JSMessagesViewDelegate,
JSMessagesViewDataSource, UINavigationControllerDelegate>{
        NSInteger       _lastMessageIdToShow;
}

@property (strong, nonatomic) NSString *friendName;
@property (strong, nonatomic) NSString *peerName;
@end

@implementation ZXHistoryMessageViewController

-(id)initWithPeerName:(NSString*)peerName andFriendName:(NSString*)friendName;{
        self = [super init];
        if(self){
                self.friendName =friendName;
                self.peerName = peerName;
        }
        return self;
       
}

- (void)viewDidLoad {
        [super viewDidLoad];
        [self.chatKeyBoard setHidden:YES];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_ic"]style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
        
        [leftButton setTintColor:RGBCOLOR(245, 245, 245)];
        self.navigationItem.leftBarButtonItem = leftButton;
        self.delegate = self;
        self.dataSource = self;
        self.title = self.friendName;
        
        _lastMessageIdToShow = LONG_MAX;
        self.mMsgList = [[DataBaseManager getInstance] loadHistoryMessages:self.peerName
                                                                withLastId:&_lastMessageIdToShow];
        
        [self finishSend];
}

-(void)backHome{
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.mMsgList.count;
}
//点击cell跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
        NSString * messageSendTime = @"4356653";
        if (messageSendTime.length > 0) {
                NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:[messageSendTime intValue]];
                return currentTime;
        }
        return nil;
}


#pragma mark - 聊天头像
- (UIImage *)avatarImageForIncomingMessage{
        UIImageView *imageView = [UIImageView new];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.peerHeaderURL] placeholderImage:[UIImage imageNamed:@"head_img"]];
        
        return imageView.image;
}


- (UIImage *)avatarImageForOutgoingMessage{
        
        NSString *imagePhone =  @"http:";
        
        UIImageView *imageView = [UIImageView new];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imagePhone] placeholderImage:[UIImage imageNamed:@"head_img"]];
        
        return imageView.image;
}


- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
        return nil;
}

- (void)beginToRefreshData:(FJPullTableView *)tableView {//模拟刷新操作
        dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger affected_rows = 1;
                if (affected_rows == 0){
                        [self.tableView setIsShowRefresh:NO];
                        [self.tableView fjPullScrollViewDataSourceDidFinishedLoading:self.tableView isRefresh:NO];
                }
                [self.tableView fjPullScrollViewDataSourceDidFinishedLoading:self.tableView isRefresh:NO];
                [self.tableView reloadData];
        });
}


@end
