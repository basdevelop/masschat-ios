//
//  InvitationMession.h
//  MassChat
//
//  Created by wsli on 2017/9/2.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM (NSInteger, InvitationMissionType) {
        InvitationMissionTypeFile,
        InvitationMissionTypeGroup,
        InvitationMissionTypeGame
};

@interface InvitationMission : NSObject<NSCoding>
@property(nonatomic) InvitationMissionType      type;
@property(nonatomic) BOOL                       isOwner;
@property(nonatomic, strong) NSString*          parameter;

+(NSData*)generateData:(InvitationMission*)obj;

+(InvitationMission*)initWithData:(NSData*)data;

@end
