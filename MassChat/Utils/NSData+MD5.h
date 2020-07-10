//
//  NSData+MD5.h
//  MassChat
//
//  Created by wsli on 2017/8/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MD5)
+(NSData *)MD5Digest:(NSData *)input;
-(NSData *)MD5Digest;

+(NSString *)MD5HexDigest:(NSData *)input;
-(NSString *)MD5HexDigest;
@end
