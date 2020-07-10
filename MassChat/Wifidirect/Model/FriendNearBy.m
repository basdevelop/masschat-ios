//
//  FriendNearBy.m
//  MassChat
//
//  Created by wsli on 2017/8/23.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "FriendNearBy.h"

@implementation FriendNearBy
@synthesize name, peerName, gender, title, company, address, peerId,
connectStatus, unreadMessage, lastMessage, updateTime,
signature, avatar,useDefaultAatar;

+(id)createDefaultInfo{
        FriendNearBy* bean = [FriendNearBy new];
        
        [bean setName:@"未设置"];
        [bean setGender:@"男"];
        [bean setTitle:@"CEO"];
        [bean setCompany:@"四十大盗"];
        [bean setAddress:@"杭州西葫芦32号"];
        [bean setSignature:@"不一样的烟火"];
        [bean setUseDefaultAatar:YES];
        return bean;
}

+(FriendNearBy*) fromDicData:(NSDictionary*)dic{
        FriendNearBy* bean = [FriendNearBy new];
        
        [bean setName:   [dic objectForKey:@"name"]];
        [bean setGender: [dic objectForKey:@"gender"]];
        [bean setTitle:  [dic objectForKey:@"title"]];
        [bean setCompany:[dic objectForKey:@"company"]];
        [bean setAddress:[dic objectForKey:@"address"]];
        [bean setSignature:[dic objectForKey:@"signature"]];
        [bean setUseDefaultAatar:[[dic objectForKey:@"useDefaultAatar"] boolValue]];
        
        return bean;
}

-(NSDictionary*) convertToDic{
        
        return @{@"name":name == nil?@"":name,
                 @"title":title == nil?@"":title,
                 @"gender":gender == nil?@"":gender,
                 @"address":address == nil?@"":address,
                 @"company":company == nil?@"":company,
                 @"signature":signature == nil?@"":signature,
                 @"useDefaultAatar": [NSString stringWithFormat:@"%d", useDefaultAatar]
                 };
}

#pragma mark - delegate for NSCoding.
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
                self.title = [aDecoder decodeObjectForKey:@"title"];
                self.name = [aDecoder decodeObjectForKey:@"name"];
                self.gender = [aDecoder decodeObjectForKey:@"gender"];
                self.company = [aDecoder decodeObjectForKey:@"company"];
                self.address = [aDecoder decodeObjectForKey:@"address"];
                self.signature = [aDecoder decodeObjectForKey:@"signature"];
                self.useDefaultAatar = [aDecoder decodeBoolForKey:@"useDefaultAatar"];

	}
        return self;
}
                               
- (void)encodeWithCoder:(NSCoder *)aCoder {
        
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:gender forKey:@"gender"];
	[aCoder encodeObject:company forKey:@"company"];
        [aCoder encodeObject:address forKey:@"address"];
        [aCoder encodeObject:signature forKey:@"signature"];
        [aCoder encodeBool:useDefaultAatar forKey:@"useDefaultAatar"];
}

//NSData *data = [NSKeyedArchiver archivedDataWithRootObj:obj];
//BookObj *obj = [NSKeyedUnarchiver unarchivedObjectWithData:data];
@end
