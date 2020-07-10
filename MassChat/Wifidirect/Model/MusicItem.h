//
//  MusicItem.h
//  MassChat
//
//  Created by wsli on 2017/9/7.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicItem : NSObject
@property(nonatomic) NSInteger         musicId;
@property(nonatomic, strong)NSString*  fileName;
@property(nonatomic, strong)NSURL*     fileUrl;
@property(nonatomic, strong)NSDate*    createTime;
@end
