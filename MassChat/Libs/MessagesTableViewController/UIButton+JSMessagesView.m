//
//  UIButton+JSMessagesView.m
//  MessagesDemo
//
//  Created by Jesse Squires on 3/24/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//

#import "UIButton+JSMessagesView.h"
#import "JSMessageInputView.h"

@implementation UIButton (JSMessagesView)

+ (UIButton *)defaultSendButton
{
    UIButton *sendButton;
    
    if ([JSMessageInputView inputBarStyle] == JSInputBarStyleFlat)
    {
        sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        NSString *title = NSLocalizedString(@"发送", @"发送");
        [sendButton setTitle:title forState:UIControlStateNormal];
        [sendButton setTitle:title forState:UIControlStateHighlighted];
        [sendButton setTitle:title forState:UIControlStateDisabled];
        [sendButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        sendButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    }
    else
    {
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *sendBack = [UIImage imageNamed:@"send_btn.png"];
        UIImage *sendBackHighLighted = [UIImage imageNamed:@"send_btn.png"];
        [sendButton setBackgroundImage:sendBack forState:UIControlStateNormal];
        [sendButton setBackgroundImage:sendBack forState:UIControlStateDisabled];
        [sendButton setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
        
        sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        UIColor *titleShadow = [UIColor grayColor];
        [sendButton setTitleShadowColor:titleShadow forState:UIControlStateNormal];
        [sendButton setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
        sendButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
        
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [sendButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    }
    

    
    return sendButton;
}

@end