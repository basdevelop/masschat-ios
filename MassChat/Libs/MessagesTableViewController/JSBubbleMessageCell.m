//
//  JSBubbleMessageCell.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSBubbleMessageCell.h"
#import "UIColor+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import "ZXChatViewController.h"

#define TIMESTAMP_LABEL_HEIGHT 14.5f

@interface JSBubbleMessageCell()

@property (strong, nonatomic) JSBubbleView *bubbleView;
@property (strong, nonatomic) UILabel *timestampLabel;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (assign, nonatomic) JSAvatarStyle avatarImageStyle;
@property (assign, nonatomic) JSBubbleMessageType messageType;
- (void)setup;
- (void)configureTimestampLabel;

- (void)configureWithType:(JSBubbleMessageType)type
              bubbleStyle:(JSBubbleMessageStyle)bubbleStyle
              avatarStyle:(JSAvatarStyle)avatarStyle
                mediaType:(JSBubbleMediaType)mediaType
                timestamp:(BOOL)hasTimestamp;

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress;
- (void)handleMenuWillHideNotification:(NSNotification *)notification;
- (void)handleMenuWillShowNotification:(NSNotification *)notification;

@end



@implementation JSBubbleMessageCell

#pragma mark - Setup
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
//    self.alpha = 1.0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.imageView.image = nil;
    UIView *tmp=[[UIView alloc] init];
    [self setBackgroundView:tmp];
//    [[tmp layer] setBorderWidth :1];
    [[tmp layer]setBorderColor:[[UIColor grayColor] CGColor]];
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(handleLongPress:)];
    [recognizer setMinimumPressDuration:0.4];
    [self addGestureRecognizer:recognizer];
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self addGestureRecognizer:singleRecognizer];
    

}


- (void)configureTimestampLabel
{
    self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    4.0f,
                                                                  kscreenWidth,
                                                                    TIMESTAMP_LABEL_HEIGHT)];
//    self.timestampLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    self.timestampLabel.backgroundColor = [UIColor clearColor];
    self.timestampLabel.textAlignment = NSTextAlignmentCenter;
    self.timestampLabel.textColor = RGBCOLOR(153, 153, 153);
//    self.timestampLabel.shadowColor = [UIColor whiteColor];
//    self.timestampLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.timestampLabel.font = [UIFont systemFontOfSize:13.f];
    
    [self.contentView addSubview:self.timestampLabel];
    [self.contentView bringSubviewToFront:self.timestampLabel];
}

- (void)configureWithType:(JSBubbleMessageType)type
              bubbleStyle:(JSBubbleMessageStyle)bubbleStyle
              avatarStyle:(JSAvatarStyle)avatarStyle
                mediaType:(JSBubbleMediaType)mediaType
                timestamp:(BOOL)hasTimestamp
{
    CGFloat bubbleY = 0.0f;
    CGFloat bubbleX = 0.0f;
        self.messageType = type;
    if(hasTimestamp) {
        [self configureTimestampLabel];
        bubbleY = 14.0f;
    }
    
    CGFloat offsetX = 6.0f;
    
    if(avatarStyle != JSAvatarStyleNone) {
        offsetX = 4.0f;
        bubbleX = kJSAvatarSize;
        CGFloat avatarX = 0.5f;
        
        if(type == JSBubbleMessageTypeOutgoing) {
            avatarX = (self.contentView.frame.size.width - kJSAvatarSize);
            offsetX = kJSAvatarSize - 4.0f;
        }
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarX,
                                                                             6 + bubbleY,
                                                                             kJSAvatarSize,
                                                                             kJSAvatarSize)];
        
        self.avatarImageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin
                                                 | UIViewAutoresizingFlexibleLeftMargin
                                                 | UIViewAutoresizingFlexibleRightMargin);
        [self.contentView addSubview:self.avatarImageView];
    }
    
    CGRect frame = CGRectMake(bubbleX - offsetX,
                              self.avatarImageView.y,
                              self.contentView.frame.size.width - bubbleX,
                              self.contentView.frame.size.height - self.timestampLabel.frame.size.height);
    
    self.bubbleView = [[JSBubbleView alloc] initWithFrame:frame
                                               bubbleType:type
                                              bubbleStyle:bubbleStyle
                                                mediaType:mediaType];

    [self.contentView addSubview:self.bubbleView];
    [self.contentView sendSubviewToBack:self.bubbleView];
}


#pragma mark - Initialization
- (id)initWithBubbleType:(JSBubbleMessageType)type
             bubbleStyle:(JSBubbleMessageStyle)bubbleStyle
             avatarStyle:(JSAvatarStyle)avatarStyle
               mediaType:(JSBubbleMediaType)mediaType
            hasTimestamp:(BOOL)hasTimestamp
         reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        [self setup];
        self.avatarImageStyle = avatarStyle;
        [self configureWithType:type
                    bubbleStyle:bubbleStyle
                    avatarStyle:avatarStyle
                      mediaType:mediaType
                      timestamp:hasTimestamp];
    }
    return self;
}

- (void)dealloc
{
    self.bubbleView = nil;
    self.timestampLabel = nil;
    self.avatarImageView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters
- (void)setBackgroundColor:(UIColor *)color
{
    [super setBackgroundColor:color];
    [self.contentView setBackgroundColor:color];
//    [self.bubbleView setBackgroundColor:color];
    
}

#pragma mark - Message Cell
- (void)setMessage:(NSString *)msg
{
    self.bubbleView.text = msg;
    //
    if ([msg isEqualToString:@"4000310300"] ||[msg isEqualToString:@"jucaicun.com"]) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(63, 48, 75, 1)];
        lineView.backgroundColor = [UIColor blueColor];
        [self addSubview:lineView];
    }
}


- (void)setMedia:(id)data
{
	if ([data isKindOfClass:[UIImage class]])
	{
		// image
		NSLog(@"show the image here");
        self.bubbleView.data = data;
	}
	else if ([data isKindOfClass:[NSData class]])
	{
		// show a button / icon to view details
		NSLog(@"icon view");
	}
}


- (void)setTimestamp:(NSDate *)date
{
    NSString *timeStr = [self compareDate:date];
    
    self.timestampLabel.text = timeStr;
//    self.timestampLabel.text = [NSDateFormatter localizedStringFromDate:date
//                                                              dateStyle:kCFDateFormatterMediumStyle
//                                                              timeStyle:NSDateFormatterShortStyle];
}
-(NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate: date];
        return currentDateStr;
    } else if ([dateString isEqualToString:yesterdayString])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"昨天 HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate: date];
        return currentDateStr;
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return nil;
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate: date];
        return currentDateStr;
    }
}

- (void)setAvatarImage:(UIImage *)image
{
    UIImage *styledImg = nil;
    switch (self.avatarImageStyle) {
        case JSAvatarStyleCircle:
            styledImg = [image circleImageWithSize:kJSAvatarSize];
            break;
            
        case JSAvatarStyleSquare:
            styledImg = [image squareImageWithSize:kJSAvatarSize];
            break;
            
        case JSAvatarStyleNone:
        default:
            break;
    }
    
    self.avatarImageView.image = styledImg;
//    self.avatarImageView.userInteractionEnabled = YES;
//    UIGestureRecognizer *singleTap =           [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(UesrClicked)];
//    [self.avatarImageView addGestureRecognizer:singleTap];

}
//-(void)UesrClicked
//{
//    NSLog(@"点击");
//}

+ (CGFloat)neededHeightForText:(NSString *)bubbleViewText timestamp:(BOOL)hasTimestamp avatar:(BOOL)hasAvatar
{
    CGFloat timestampHeight = (hasTimestamp) ? TIMESTAMP_LABEL_HEIGHT : 0.0f;
    CGFloat avatarHeight = (hasAvatar) ? kJSAvatarSize : 0.0f;
    return MAX(avatarHeight, [JSBubbleView cellHeightForText:bubbleViewText]) + timestampHeight;
}

+ (CGFloat)neededHeightForImage:(UIImage *)bubbleViewImage timestamp:(BOOL)hasTimestamp avatar:(BOOL)hasAvatar{
    CGFloat timestampHeight = (hasTimestamp) ? TIMESTAMP_LABEL_HEIGHT : 0.0f;
    CGFloat avatarHeight = (hasAvatar) ? kJSAvatarSize : 0.0f;
    return MAX(avatarHeight, [JSBubbleView cellHeightForImage:bubbleViewImage]) + timestampHeight;
}

#pragma mark - Copying
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(self.bubbleView.data){
        if(action == @selector(saveImage:))
            return YES;
    }else{
        if(action == @selector(copy:))
            return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.bubbleView.text];
    [self resignFirstResponder];
}

#pragma mark - Touch events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if(![self isFirstResponder])
        return;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
    [menu update];
    [self resignFirstResponder];
}
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
#pragma mark - Gestures
- (void) handleSingleTapFrom:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    ZXChatViewController *chatVC = (ZXChatViewController *)[self viewController];
        if (!self.personID) {
                return;
        }
        [chatVC.chatKeyBoard keyboardDown];
        if (self.messageType ==
            JSBubbleMessageTypeIncoming) {
                if (self.avatarImageView.width > point.x && point.y < self.avatarImageView.height) {
#pragma mark 点击头像跳转用户页面
                        return;
                }
                
        }else{
                if (self.avatarImageView.frame.origin.x < point.x && point.y > self.avatarImageView.frame.origin.y) {
#pragma mark 点击头像跳转用户页面
                        return;
                }
        }

    return;
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state != UIGestureRecognizerStateBegan
       || ![self becomeFirstResponder])
        return;
    
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *saveItem;
    if(self.bubbleView.data){
        saveItem = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(saveImage:)];
    }else{
        saveItem = nil;
    }
    
    [menu setMenuItems:[NSArray arrayWithObjects:saveItem, nil]];
    
    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
                                 fromView:self.bubbleView];
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
    
    [menu update];
}

#pragma mark - Save Image
-(void)saveImage:(id)sender{
    
    
    
    
    UIImageWriteToSavedPhotosAlbum(self.bubbleView.data, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
	UIAlertController * alert;
	if (error != NULL){
             alert = [UIAlertController alertControllerWithTitle:@"Save Error"
                                         message:[error localizedDescription]
                                         preferredStyle:UIAlertControllerStyleAlert];
        
	}else{
            alert = [UIAlertController alertControllerWithTitle:@"Save Success"
                                                        message:@"Image has Saved !"
                                                 preferredStyle:UIAlertControllerStyleAlert];
	}
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alert animated:YES completion:nil];
}




#pragma mark - Notification
- (void)handleMenuWillHideNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
    self.bubbleView.selectedToShowCopyMenu = NO;
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
    
    self.bubbleView.selectedToShowCopyMenu = YES;
}

@end
