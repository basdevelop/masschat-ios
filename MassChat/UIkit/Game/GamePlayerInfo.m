//
//  GamePlayerInfo.m
//  MassChat
//
//  Created by wsli on 2017/9/13.
//  Copyright © 2017年 众信. All rights reserved.
//
#import "ZXUser.h"
#import "GamePlayerInfo.h"

@implementation GamePlayerInfo
@synthesize imageData, nickName, coinsNo, isRoomOwner;

- (id)initWithCoder:(NSCoder *)aDecoder {
        if (self =[super init]){
                self.imageData = [aDecoder decodeObjectForKey:@"imageData"];
                self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
                self.coinsNo = [aDecoder decodeIntegerForKey:@"coinsNo"];
                self.isRoomOwner = [aDecoder decodeBoolForKey:@"isRoomOwner"];
        }
        
        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeObject:imageData forKey:@"imageData"];
        [aCoder encodeObject:nickName forKey:@"nickName"];
        [aCoder encodeInteger:coinsNo forKey:@"coinsNo"];
        [aCoder encodeBool:isRoomOwner forKey:@"isRoomOwner"];
}

+(NSData*)generateData:(GamePlayerInfo*)obj{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        return data;
}

+(GamePlayerInfo*)initWithData:(NSData*)data{
        GamePlayerInfo* bean = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return bean;
}

+(GamePlayerInfo*)loadSelfInfo{
        GamePlayerInfo* bean = [GamePlayerInfo new];
        bean.coinsNo = 100;
        
        ZXUser* user_info = [ZXUser loadSelfProfile];
        bean.nickName = user_info.name == nil ? user_info.nickName : user_info.name;
        
        if (user_info.avatar){
                bean.imageData = UIImagePNGRepresentation(user_info.avatar);
        }else{
                bean.imageData = nil;
        }
        
        return bean;
}

@end
