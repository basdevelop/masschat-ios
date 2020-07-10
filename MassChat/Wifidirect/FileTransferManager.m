//
//  FileTransferManager.m
//  MassChat
//
//  Created by wsli on 2017/8/29.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "FileTransferManager.h"
#import "WifiDirectManager.h"
#import "TransportTask.h"
#import <Photos/Photos.h>
#import "TransPortRecord.h"
#import "DataBaseManager.h"
#import "MusicItem.h"

@implementation FileTransferManager
@synthesize sendTaskCache, receiveTaskCache, currentShowingQRData;


static  FileTransferManager  *_instance = nil;
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
                sendTaskCache = [NSMutableDictionary new];
                receiveTaskCache = [NSMutableDictionary new];
                currentShowingQRData = nil;                 
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self removeAllTmpFiles];
                });
        }
        
        return self;
}

-(void)removeAllTmpFiles{
         //TDOO::remove all tmp files when init.
}


-(BOOL)startLoadFile:(NSString*)QRString   withDelegate:(id<TransportTaskDelegate>)delegate{
        
        NSArray<NSString *>* data = [QRString componentsSeparatedByString:QRCODE_SPERATOR_FOR_SCAN_RESULT];
        if (data.count != 2){
                return NO;
        }
        NSString* path = data[0];
        NSString* peer_name = data[1];
        MCSession* connected_session = [[WifiDirectManager getInstance] getCachedSession:peer_name];
        
        TransportTask* task = [TransportTask new];
        task.direction = TransportTaskTypeReceive;
        task.tag = QRString;
        task.delegate = delegate;
        [receiveTaskCache setObject:task forKey:task.tag];
        
        if (nil != connected_session){
                MessageBean* ctrl_msg = [MessageBean new];
                [ctrl_msg setText:path];
                [ctrl_msg setType:MessageBeanTypeTransCtl];
                
                return [[WifiDirectManager getInstance] sendMessage:ctrl_msg withPeerName:peer_name];
        }else{
                [[WifiDirectManager getInstance] connectPeer:peer_name forTransport:path];
                return YES;
        }
}

-(void)startSendUrlRecource:(NSString*)path bySession:(MCSession*)session forPeer:(MCPeerID*)peerID{
        
        NSString* file_name = currentShowingQRData.fileDisplayName;
        
        NSString* key = [currentShowingQRData generateString:peerID.displayName];
        NSProgress *progress = [session sendResourceAtURL:currentShowingQRData.url
                                withName:path
                               toPeer:peerID withCompletionHandler:^(NSError * error) {
                if (error){
                          NSLog(@"返回结果:%@", error);
                          //TODO:: 处理发送失败的情况.
                        return;
                }
               [self sendUrlRecourceFinished:key];
        }];
        
        TransportTask* task = [TransportTask new];
        task.direction = TransportTaskTypeSend;
        task.progress = progress;
        task.peerID = peerID;
        task.fileName = file_name;
        task.tag = key;
        [sendTaskCache setObject:task forKey:task.tag];
        
        [currentShowingQRData.delegate didStartSendImage];
}

-(void)sendUrlRecourceFinished:(NSString*)key{
        NSLog(@"====返回结果==成功====");
        
        TransportTask* task = [sendTaskCache objectForKey:key];
        TransPortRecord* record = [TransPortRecord new];
        
        [record setSenderPeerName:[[WifiDirectManager getInstance] mcPeerID].displayName];
        [record setCreateTime:[NSDate date]];
        [record setReceiverPeerName:task.peerID.displayName];
        [record setDirectionForMe:NO];
        [record setFileName:task.fileName];
        [record setFileSize:[TransportTask calculateFileSize:task.progress.totalUnitCount]];
        
        [[DataBaseManager getInstance] saveTransRecord: record];
        
        
        [sendTaskCache removeObjectForKey:key];        
        [currentShowingQRData.delegate didFinishedSendImage];
}

-(void)setCurrentShowingQRData:(QRCodeItemToSend *)data{
        
        NSString* url_path = [data.url absoluteString];
       
        if (nil != currentShowingQRData &&  ![currentShowingQRData.url.absoluteString isEqualToString:url_path]){
                NSError *error = nil;
                BOOL ret = [[NSFileManager defaultManager] removeItemAtURL:currentShowingQRData.url error:&error];
                if (!ret) {
                        NSLog(@"删除临时文件出错：err = %@", error);
                }
        }
        
        currentShowingQRData = data;
}

-(void)startReceiveUrlRecource:(NSString*)resourceName bySession:(MCSession*)session
                       forPeer:(MCPeerID*)peerID withProgress:(NSProgress*)progress{
        
        NSString* key = [QRCodeItemToSend generateString:resourceName withPeerName:peerID.displayName];
        
        TransportTask* task = [receiveTaskCache objectForKey:key];
        task.progress = progress;
        task.peerID = peerID;
        task.fileName =  [[[NSURL fileURLWithPath:resourceName] lastPathComponent] stringByRemovingPercentEncoding];
        [task.delegate didStartReceiveImage];
}

-(NSString*)checkFileType:(NSString*)fileName{
        CFStringRef fileExtension = (__bridge CFStringRef) fileName;
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
        
        NSString* type = nil;
        if (UTTypeConformsTo(fileUTI, kUTTypeImage)) type= (NSString*)kUTTypeImage;
        else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) type = (NSString*)kUTTypeMovie;
        else if (UTTypeConformsTo(fileUTI, kUTTypeText)) type = (NSString*)kUTTypeText;
        else if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) type = (NSString*)kUTTypeAudio;
        
        CFRelease(fileUTI);
        
        return type;
}

-(NSURL*)portTmpFile:(NSString*)tempPath fromTask:(TransportTask*)task atURL:(NSURL*)localURL{
        
        NSURL* dest_url = [NSURL fileURLWithPath:tempPath];
        
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:tempPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
        
        NSError* error_move=nil;
        BOOL ret = [[NSFileManager defaultManager] moveItemAtURL:localURL toURL:dest_url error:&error_move];
        if (!ret){
                task.fileName = @"文件传输失败";
                NSLog(@"文件传输失败%@", error_move);
                [task.delegate didFinishedReceiveImage:@"启动传输失败,请检查对方是否开启wifi或者蓝牙"];
                return nil;
        }
        return dest_url;
}

-(void)saveReceiveAction:(TransportTask*)task{
        
        TransPortRecord* record = [TransPortRecord new];
        
        [record setSenderPeerName:task.peerID.displayName];
        [record setCreateTime:[NSDate date]];
        [record setReceiverPeerName:[[WifiDirectManager getInstance] mcPeerID].displayName];
        [record setDirectionForMe:YES];
        [record setFileName:task.fileName];
        [record setFileSize:[TransportTask calculateFileSize:task.progress.totalUnitCount]];
        
        [[DataBaseManager getInstance] saveTransRecord: record];
}

-(void)didFinishedReceive:(NSString*)resourceName atURL:(NSURL*)localURL
                  forPeer:(MCPeerID*)peerID withError:(NSError*)error{
        
        NSString* key = [QRCodeItemToSend generateString:resourceName withPeerName:peerID.displayName];
        TransportTask* task = [receiveTaskCache objectForKey:key];
        if (error){
                task.fileName = @"文件传输失败";
                [task.delegate didFinishedReceiveImage:@"传输失败,请保存手机唤醒状态重试"];
                NSLog(@"文件传输失败%@", error);
                return;
        }
        
        [self saveReceiveAction:task];
        
        NSString* media_type = [self checkFileType:[task.fileName pathExtension]];
        if ([media_type isEqualToString: (NSString *)kUTTypeAudio]){
                
                 NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *temp_path = [NSString stringWithFormat:@"%@/%@", docDirPath, task.fileName];
                
                NSURL* dest_url = [self portTmpFile:temp_path fromTask:task atURL:localURL];
                
                NSLog(@"文件保存到==>>>%@", dest_url);
                MusicItem* music_item = [MusicItem new];
                [music_item setFileName:task.fileName];
                [music_item setFileUrl:dest_url];
                [music_item setCreateTime:[NSDate date]];
                [[DataBaseManager getInstance] saveMusic:music_item];
                [receiveTaskCache removeObjectForKey:key];
                [task.delegate didFinishedReceiveImage:@"传输成功,请到 我的->音乐 中查看传输文件"];
                
                return ;
        }
        
        
        NSString *temp_path = [NSTemporaryDirectory() stringByAppendingPathComponent:task.fileName];
        NSURL* dest_url = [self portTmpFile:temp_path fromTask:task atURL:localURL];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                if([media_type isEqualToString: (NSString *)kUTTypeMovie]){
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:dest_url];
                }else if ([media_type isEqualToString: (NSString *)kUTTypeImage]){
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:dest_url];
                }
        } completionHandler:^(BOOL success, NSError * error) {
                
                NSError *error_delete = nil;
                BOOL ret = [[NSFileManager defaultManager] removeItemAtURL:dest_url error:&error_delete];
                
                if (!ret) {
                        NSLog(@"删除接受的临时文件出错：err = %@", error_delete);
                }
                if (error) {
                        task.fileName = @"文件传输失败";
                        NSLog(@"文件传输失败%@", error);
                        [task.delegate didFinishedReceiveImage:@"保存文件失败，请到设置->隐私中查看权限设置"];
                }else{
                        [receiveTaskCache removeObjectForKey:key];
                        [task.delegate didFinishedReceiveImage:@"传输成功，请到<图片>APP中查看传输内容"];
                }
        }];
}
@end
