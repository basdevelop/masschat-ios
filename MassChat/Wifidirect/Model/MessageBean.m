//
//  MessageBean.m
//  MassChat
//
//  Created by wsli on 2017/8/25.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "MessageBean.h"

@implementation MessageBean
@synthesize text, type, time, inMsg, binData, status;

- (id)initWithCoder:(NSCoder *)aDecoder {
        
        if (self = [super init]) {
                self.text = [aDecoder decodeObjectForKey:@"text"];
                self.type = (MessageBeanType)[aDecoder decodeIntForKey:@"type"];
                self.time = [aDecoder decodeObjectForKey:@"time"];
                self.inMsg = [aDecoder decodeBoolForKey:@"inMsg"];
                self.binData = [aDecoder decodeObjectForKey:@"binData"];
                self.status = [aDecoder decodeBoolForKey:@"status"];
        }
        
        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeObject:text forKey:@"text"];
        [aCoder encodeInt:type forKey:@"type"];
        [aCoder encodeObject:time forKey:@"time"];
        [aCoder encodeBool:inMsg forKey:@"inMsg"];
        [aCoder encodeObject:binData forKey:@"binData"];
        [aCoder encodeBool:status forKey:@"status"];
}


+(NSData*)generateData:(MessageBean*)obj{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        return data;
}

+(MessageBean*)initWithData:(NSData*)data{
        MessageBean* bean = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return bean;
}

-(NSString*)toString{
        return [NSString stringWithFormat:@"MessageBean=[text=%@, type=%ld, time=%@]", text, (long)type, time];
}

@end
