//
//  TransPortRecord.h
//  MassChat
//
//  Created by wsli on 2017/9/4.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransPortRecord : NSObject
@property(nonatomic) NSInteger  recordId;
@property(nonatomic, strong)NSString*   senderPeerName;
@property(nonatomic, strong)UIImage*    senderImg;
@property(nonatomic, strong)NSString*   receiverPeerName;
@property(nonatomic, strong)UIImage*    receiverImg;
@property(nonatomic, strong)NSDate*     createTime;
@property(nonatomic, strong)NSString*   fileName;
@property(nonatomic, strong)NSString*   fileSize;
@property(nonatomic)BOOL                directionForMe;
@end
