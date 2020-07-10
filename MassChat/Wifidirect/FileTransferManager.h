//
//  FileTransferManager.h
//  MassChat
//
//  Created by wsli on 2017/8/29.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportTask.h"
#import "QRCodeItemToSend.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>


@interface FileTransferManager : NSObject

@property(nonatomic, strong)NSMutableDictionary*        sendTaskCache;
@property(nonatomic, strong)NSMutableDictionary*        receiveTaskCache;
@property(nonatomic, strong)QRCodeItemToSend*           currentShowingQRData;

+(id)getInstance;

-(BOOL)startLoadFile:(NSString*)filePath withDelegate:(id<TransportTaskDelegate>)delegate;

-(void)startSendUrlRecource:(NSString*)path bySession:(MCSession*)session forPeer:(MCPeerID*)peerID;

-(void)startReceiveUrlRecource:(NSString*)resourceName bySession:(MCSession*)session
                       forPeer:(MCPeerID*)peerID withProgress:(NSProgress*)progress;

-(void)didFinishedReceive:(NSString*)resourceName atURL:(NSURL*)localURL
                  forPeer:(MCPeerID*)peerID withError:(NSError*)error;
@end
