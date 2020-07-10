//
//  MessageManager.m
//  MassChat
//
//  Created by wsli on 2017/8/25.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "MessageManager.h"
#import "WifiDirectManager.h"
#import "DataBaseManager.h"

@interface MessageManager(){
        
        NSMutableDictionary*    _messageCache;
        
        NSMutableDictionary*    _receivedMessageListener;
}
@end

@implementation MessageManager 


static  MessageManager  *_instance = nil; 
+ (id)getInstance {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                _instance = [[self alloc] init];
        });
        return _instance;
}


-(id) init{
        self = [super init];
        if (self){
                _messageCache = [NSMutableDictionary new];
                _receivedMessageListener = [NSMutableDictionary new];

        }
        return self;
}

-(Boolean)sendMessage:(MessageBean*)msg withPeerName:(NSString*) peerName{
        
        [[DataBaseManager getInstance] saveMessage:msg withPeerName:peerName];
        
        return [[WifiDirectManager getInstance] sendMessage:msg withPeerName:peerName];
}


-(NSUInteger)receiveMessage:(MessageBean*)msg withPeerName:(NSString*) peerName{
        
        [[DataBaseManager getInstance] saveMessage:msg withPeerName:peerName];
        
        id<MessageManagerDelegate> delegate = [_receivedMessageListener objectForKey:peerName];
        if (nil != delegate){
                [delegate didReceivedMessage:msg];
                return 0;
        }else{ 
                
                NSMutableArray* cached_msg = [_messageCache objectForKey:peerName];
                
                if (nil == cached_msg){
                        cached_msg = [NSMutableArray new];
                        [_messageCache setObject:cached_msg forKey:peerName];
                }
                
                [cached_msg addObject:msg];
                
                return [cached_msg count];
        }
}

-(void)registerDelegate:(id<MessageManagerDelegate>) delegate withPeerName:(NSString*) peerName{
        [_receivedMessageListener setObject:delegate forKey:peerName];
}
-(void)unregisterDelegateByPeerName:(NSString*) peerName{
        [_receivedMessageListener removeObjectForKey:peerName];
}

@end
