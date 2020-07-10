//
//  TransportTask.m
//  MassChat
//
//  Created by wsli on 2017/8/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "TransportTask.h"

@implementation TransportTask
@synthesize direction, progress,fileName, peerID, tag, delegate;

+(NSString*)calculateFileSize:(int64_t) fileSize{
        NSString* size_str = nil;
        
        if (fileSize > GUNIT_SIZE ){
                size_str = [NSString stringWithFormat:@"%.2fG", (float)fileSize / GUNIT_SIZE];
        }else if (fileSize > MUNIT_SIZE){
                size_str = [NSString stringWithFormat:@"%.2fM", (float)fileSize / MUNIT_SIZE];
        }else if (fileSize > KUNIT_SIZE){
                size_str = [NSString stringWithFormat:@"%.2fK", (float)fileSize / KUNIT_SIZE];
        }else{
                size_str = [NSString stringWithFormat:@"%lld", fileSize];
        }
        
        return size_str;
}
@end
