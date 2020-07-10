//
//  GameMessageBean.m
//  MassChat
//
//  Created by wsli on 2017/9/14.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "GameMessageBean.h"

@implementation GameMessageBean
@synthesize type,data;

- (id)initWithCoder:(NSCoder *)aDecoder {
        if (self = [super init]){
                self.data = [aDecoder decodeObjectForKey:@"data"];
                self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
        
        return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeObject:data forKey:@"data"];
        [aCoder encodeInteger:type forKey:@"type"];
}

+(NSData*)generateData:(GameMessageBean*)obj{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        return data;
}

+(GameMessageBean*)initWithData:(NSData*)data{
        GameMessageBean* bean = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return bean;
}

@end
