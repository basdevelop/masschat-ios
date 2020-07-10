//
//  TransportTask.h
//  MassChat
//
//  Created by wsli on 2017/8/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define KUNIT_SIZE   (1 << 10)
#define MUNIT_SIZE   (1 << 20)
#define GUNIT_SIZE   (1 << 30)


typedef NS_ENUM (NSInteger, TransportTaskDirection) {
        TransportTaskTypeSend,
        TransportTaskTypeReceive
};

@protocol TransportTaskDelegate <NSObject>
-(void) didStartSendImage;
-(void) didFinishedSendImage;
-(void) didStartReceiveImage;
-(void) didFinishedReceiveImage:(NSString*) tips;
@end

@interface TransportTask : NSObject
@property(nonatomic) TransportTaskDirection  direction;
@property(nonatomic,strong) NSProgress*   progress;
@property(nonatomic,strong) MCPeerID*     peerID;
@property(nonatomic,strong) NSString*     fileName;
@property(nonatomic,strong) NSString*     tag;
@property(strong, nonatomic)id<TransportTaskDelegate> delegate;


+(NSString*)calculateFileSize:(int64_t) fileSize;
@end
