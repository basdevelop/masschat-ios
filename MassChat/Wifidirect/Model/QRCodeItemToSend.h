//
//  QRCodeItemToSend.h
//  MassChat
//
//  Created by wsli on 2017/8/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRCodeItemToSend.h"
#import "TransportTask.h"

#define QRCODE_SPERATOR_FOR_SCAN_RESULT @"$@$"

@interface QRCodeItemToSend : NSObject
@property(strong, nonatomic)NSURL*      url;
@property(strong, nonatomic)NSString*   fileDisplayName;
//@property(strong, nonatomic)UIImage*    qrCodeImage;
@property(strong, nonatomic)id<TransportTaskDelegate> delegate;

+(NSString*)generateString:(NSString*)path withPeerName:(NSString*)peerName;
-(NSString*)generateString:(NSString*)peerName;
@end
