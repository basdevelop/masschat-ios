//
//  QRCodeItemToSend.m
//  MassChat
//
//  Created by wsli on 2017/8/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "QRCodeItemToSend.h"

@implementation QRCodeItemToSend
@synthesize url, delegate, fileDisplayName;

-(NSString*)generateString:(NSString*)peerName{
        
        NSString* result = [NSString stringWithFormat:@"%@%@%@",
                            [url absoluteString],QRCODE_SPERATOR_FOR_SCAN_RESULT, peerName];
        
        return result;
}

+(NSString*)generateString:(NSString*)path withPeerName:(NSString*)peerName{
        NSString* result = [NSString stringWithFormat:@"%@%@%@",
                            path,QRCODE_SPERATOR_FOR_SCAN_RESULT, peerName];
        
        return result;
}

@end
