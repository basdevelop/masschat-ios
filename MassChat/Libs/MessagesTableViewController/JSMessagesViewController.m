//
//  JSMessagesViewController.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//

#import "JSMessagesViewController.h"
#import "NSString+JSMessagesView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "UIColor+JSMessagesView.h"
#import "JSDismissiveTextView.h"
#define INPUT_HEIGHT 49.0f
#import "MessageBean.h"

@interface JSMessagesViewController () <JSDismissiveTextViewDelegate,UIGestureRecognizerDelegate, ChatKeyBoardDelegate, ChatKeyBoardDataSource>
@property BOOL isFirst;

@property (nonatomic, strong )NSMutableDictionary *rejectionDic;
@property (nonatomic, strong )NSMutableDictionary *personIdDic;
- (void)setup;

@end



@implementation JSMessagesViewController

#pragma mark - Initialization
- (void)setup
{
        
        
        if([self.view isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)self.view).scrollEnabled = NO;
        }
        CGSize size = self.view.frame.size;
        CGRect tableFrame = CGRectMake(0.0f, 0.0f, size.width, size.height - INPUT_HEIGHT);
        self.tableView = [[FJPullTableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView setIsShowLoadMore:NO];
        [self.tableView setIsShowRefresh:YES];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.isNotShowText = YES;
        self.tableView.pullDelegate = self;
        self.chatKeyBoard = [ChatKeyBoard keyBoard];
        self.chatKeyBoard.delegate = self;
        self.chatKeyBoard.dataSource = self;
        self.chatKeyBoard.placeHolder = @"请输入消息";
        self.chatKeyBoard.associateTableView = self.tableView;
        [self.view addSubview:self.chatKeyBoard];
        self.rejectionDic = [NSMutableDictionary dictionary];
        self.personIdDic = [NSMutableDictionary dictionary];
        [self.view addSubview:self.tableView];
        [self setBackgroundColor:[UIColor messagesBackgroundColor]];
}

#pragma mark ---textSendDelegate
//发送纯文本消息
- (void)sendTextMessage:(NSString *)text
{
        [self sendPressed:text];
        
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{   self.isFirst = YES;
        [super viewDidLoad];
        [self setup];
}

- (void)viewWillDisappear:(BOOL)animated
{
        [super viewWillDisappear:animated];
        [self setEditing:NO animated:YES];
}


- (void)dealloc
{
        self.delegate = nil;
        self.dataSource = nil;
        self.tableView = nil;
}


#pragma mark - Actions
- (void)sendPressed:(NSString *)text
{
        [self.delegate sendPressed:nil
                          withText:text];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (self.isFirst) {    //一出来就能拉倒最后一行
                        [self scrollToBottomAnimated:NO];
                self.isFirst = NO;
        } 
        JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
        JSBubbleMessageStyle bubbleStyle = [self.delegate messageStyleForRowAtIndexPath:indexPath];
        JSBubbleMediaType mediaType = [self.delegate messageMediaTypeForRowAtIndexPath:indexPath];
        BOOL isShowTime = YES;
        if (indexPath.row == 0) {
                isShowTime = YES;
        }else{
                MessageBean* msg_bean = self.mMsgList[indexPath.row - 1];
                NSInteger lastMessageSendTime = [msg_bean.time timeIntervalSince1970];
                
                msg_bean = self.mMsgList[indexPath.row];
                NSInteger nowMessageSendTime = [msg_bean.time timeIntervalSince1970];
                
                if (nowMessageSendTime - lastMessageSendTime > 60) {
                        isShowTime = YES;
                }else{
                        isShowTime = NO;
                }
        }
        
        JSAvatarStyle avatarStyle = [self.delegate avatarStyle];
        
        BOOL hasTimestamp = [self shouldHaveTimestampForRowAtIndexPath:indexPath];
        BOOL hasAvatar = [self shouldHaveAvatarForRowAtIndexPath:indexPath];
        
        NSString *CellID = [NSString stringWithFormat:@"MessageCell_%d_%d_%d_%d", type, bubbleStyle, hasTimestamp, hasAvatar];
        JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
        
        if(!cell)
                cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                                           bubbleStyle:bubbleStyle
                                                           avatarStyle:(hasAvatar) ? avatarStyle : JSAvatarStyleNone mediaType:mediaType
                                                          hasTimestamp:hasTimestamp
                                                       reuseIdentifier:CellID];
        
        if(hasTimestamp)
                [cell setTimestamp:[self.dataSource timestampForRowAtIndexPath:indexPath]];
        
        if(hasAvatar) {
                switch (type) {
                        case JSBubbleMessageTypeIncoming:
                                [cell setAvatarImage:[self.dataSource avatarImageForIncomingMessage]];
                                break;
                                
                        case JSBubbleMessageTypeOutgoing:
                                [cell setAvatarImage:[self.dataSource avatarImageForOutgoingMessage]];
                                break;
                }
        }
        
        if (kAllowsMedia)
                [cell setMedia:[self.dataSource dataForRowAtIndexPath:indexPath]];
        [cell setMessage:[self.dataSource textForRowAtIndexPath:indexPath]];
        cell.personID = self.messagePersonId;
        return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{       int messageType = [self.delegate messageMediaTypeForRowAtIndexPath:indexPath];
        if (messageType == JSBubbleMediaTypeText) {
                return [JSBubbleMessageCell neededHeightForText:[self.dataSource textForRowAtIndexPath:indexPath]
                                                      timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                                         avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]] + 5;
        }
        
        
        if([self.delegate messageMediaTypeForRowAtIndexPath:indexPath]){
                return [JSBubbleMessageCell neededHeightForText:[self.dataSource textForRowAtIndexPath:indexPath]
                                                      timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                                         avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]] + 5;
        }else{
                return [JSBubbleMessageCell neededHeightForImage:[self.dataSource dataForRowAtIndexPath:indexPath]
                                                       timestamp:[self shouldHaveTimestampForRowAtIndexPath:indexPath]
                                                          avatar:[self shouldHaveAvatarForRowAtIndexPath:indexPath]];
        }
}

#pragma mark - Messages view controller
- (BOOL)shouldHaveTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
        switch ([self.delegate timestampPolicy]) {
                case JSMessagesViewTimestampPolicyAll:
                        return YES;
                        
                case JSMessagesViewTimestampPolicyAlternating:
                        return indexPath.row % 2 == 0;
                        
                case JSMessagesViewTimestampPolicyEveryThree:
                        return indexPath.row % 3 == 0;
                        
                case JSMessagesViewTimestampPolicyEveryFive:
                        return indexPath.row % 5 == 0;
                        
                case JSMessagesViewTimestampPolicyCustom:
                        if([self.delegate respondsToSelector:@selector(hasTimestampForRowAtIndexPath:)])
                                return [self.delegate hasTimestampForRowAtIndexPath:indexPath];
                case JSMessagesViewTimestampPolicyNone:
                        return NO;
                default:
                        return NO;
        }
}

- (BOOL)shouldHaveAvatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
        switch ([self.delegate avatarPolicy]) {
                case JSMessagesViewAvatarPolicyIncomingOnly:
                        return [self.delegate messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming;
                        
                case JSMessagesViewAvatarPolicyBoth:
                        return YES;
                        
                case JSMessagesViewAvatarPolicyNone:
                default:
                        return NO;
        }
}

- (void)finishSend{
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self scrollToBottomAnimated:YES];
        });
}

- (void)scrollToBottomAnimated:(BOOL)animated{
        NSInteger rows = [self.tableView numberOfRowsInSection:0];
        
        if(rows > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:animated];
        }
}

- (void)setBackgroundColor:(UIColor *)color{
        self.view.backgroundColor = RGBCOLOR(244, 245, 246);
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
        
}

#pragma mark -- ChatKeyBoardDataSource
- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
        MoreItem *item1 = [MoreItem moreItemWithPicName:@"chatrejection_ic" highLightPicName:nil itemName:@"发送甩单"];
        MoreItem *item2 = [MoreItem moreItemWithPicName:@"chatcard_ic" highLightPicName:nil itemName:@"个人名片"];
        MoreItem *item3 = [MoreItem moreItemWithPicName:@"chatposition_ic" highLightPicName:nil itemName:@"当前位置"];
        MoreItem *item4 = [MoreItem moreItemWithPicName:@"chatwechat_ic" highLightPicName:nil itemName:@"我的微信"];
        MoreItem *item5 = [MoreItem moreItemWithPicName:@"chatphone_ic" highLightPicName:nil itemName:@"我的电话"];
        return @[item1, item2, item3,item4,item5];
}

- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems{
        ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"chatMore_btn" high:@"chatMore_btn" select:nil];
        ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"send_btn" high:@"send_btn" select:nil];
        
        return @[item2,item3];
}

- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems {
        return nil;
}

- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index{
        
}

- (void)chatKeyBoardSendText:(NSString *)text
{
        [self sendPressed:text];
        [self scrollToBottomAnimated:YES];
}

- (void)chatKeyBoardTextViewDidBeginEditing:(UITextView *)textView{
        [self scrollToBottomAnimated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [self.tableView fjPullScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
        [self.chatKeyBoard keyboardDown];
        [self.tableView fjPullScrollViewDidEndDragging:scrollView];
}

#pragma mark - json-dic

-(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
        return responseJSON;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
        
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
        
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
        
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
        return CGSizeMake(0.0f, 0.0f);
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
        
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
        
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
        
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
        
}

- (void)setNeedsFocusUpdate {
        
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
        return YES;
}

- (void)updateFocusIfNeeded {
        
}

@end
