//
//  InvitationMession.m
//  MassChat
//
//  Created by wsli on 2017/9/2.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "InvitationMission.h"

@implementation InvitationMission
@synthesize type, parameter,isOwner;

- (id)initWithCoder:(NSCoder *)aDecoder {
        
        if (self = [super init]) {
                self.isOwner = [aDecoder decodeBoolForKey:@"isOwner"];
                self.parameter = [aDecoder decodeObjectForKey:@"parameter"];
                self.type = (InvitationMissionType)[aDecoder decodeIntForKey:@"type"];
        }
        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeObject:parameter forKey:@"parameter"];
        [aCoder encodeInt:type forKey:@"type"];
        [aCoder encodeBool:isOwner forKey:@"isOwner"];
}


+(NSData*)generateData:(InvitationMission*)obj{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        return data;
}

+(InvitationMission*)initWithData:(NSData*)data{
        InvitationMission* bean = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return bean;
}

@end
