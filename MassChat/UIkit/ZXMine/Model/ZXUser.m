//
//  ZXUser.m
//  ZX
//
//  Created by 许李超 on 17/7/23.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXUser.h"
#import "FriendNearBy.h"
#import "NetWorkManager.h"
#define USER_BASIC_INFO_IN_LOCAL        @"USER_BASIC_INFO_IN_LOCAL"

@implementation ZXUser
@synthesize wechatId,name,phone,nickName,gender,title,company,address, avatar,signature;

static  ZXUser  *_instance = nil;

+(instancetype)loadSelfProfile{
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults dataForKey:USER_BASIC_INFO_IN_LOCAL];
                
                if (nil == data){
                        _instance = [[self alloc] init];
                        FriendNearBy* friend = [FriendNearBy createDefaultInfo];
                        _instance.nickName = friend.name;
                        _instance.gender = friend.gender;
                        _instance.title = friend.title;
                        _instance.company = friend.company;
                        _instance.address = friend.address;
                        _instance.signature = friend.signature;
                        
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_instance];
                        [defaults setObject:data forKey:USER_BASIC_INFO_IN_LOCAL];
                        [defaults synchronize];
                }else{
                        _instance = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
                
        });
        
        return _instance;
}

+(void)initSelfByWixinInfo:(SendAuthResp*)resp{
        
        NSString* url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx2e63bc383f45369f&secret=1b9217f18a8e020b5f3eaf5f9a8d3d9c&code=%@&grant_type=authorization_code", resp.code];
        
        [NetWorkManager requestWithType:HttpRequestTypeGet withUrlString:url withParaments:nil withSuccessBlock:^(NSDictionary *object) {
                NSLog(@"访问网络成功:%@", object);
                NSString* access_token = [object objectForKey:@"access_token"];
                NSString* open_id = [object objectForKey:@"openid"];
                [self loadBasicWeixinInfo:access_token openId:open_id];
        } withFailureBlock:^(NSError *error) {
                NSLog(@"访问网络失败:%@", error);
//                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示框"message:@"访问网络失败" preferredStyle:UIAlertControllerStyleAlert];
//                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction*_Nonnullaction) {
//                        NSLog(@"点击确定触发的事件"); 
//                }]];
//                
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                        [self presentViewController:alertController animated:YES completion:nil];
//                });
        } progress:^(float progress){
                 NSLog(@"访问网络进度:%f", progress);
        }];
        
}

+(void)loadBasicWeixinInfo:(NSString*)accessToken openId:(NSString*)openId{
        
        NSString* url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openId];
        [NetWorkManager requestWithType:(HttpRequestTypeGet) withUrlString:url withParaments:nil withSuccessBlock:^(NSDictionary *object) {
                NSLog(@"访问网络成功:%@", object);
                
                ZXUser* wechat_user = [ZXUser loadSelfProfile];
                [wechat_user setWechatId:[object objectForKey:@"openid"]];
                NSString* gender = [[object objectForKey:@"sex"] intValue] == 1?@"男":@"女";
                [wechat_user setGender:gender];
                [wechat_user setNickName:[object objectForKey:@"nickname"]];
                
                NSURL *image_url = [NSURL URLWithString:[object objectForKey:@"headimgurl"]];
                NSData* image_data = [NSData dataWithContentsOfURL:image_url];
                UIImage* image = [UIImage imageWithData:image_data];
                [wechat_user setAvatar:image];
                
                [self syncDataToSavePath:wechat_user];
                
        } withFailureBlock:^(NSError *error) {
                 NSLog(@"访问网络失败:%@", error);
        } progress:^(float progress) {
                 NSLog(@"访问网络进度:%f", progress);
        }];
}
+(void)syncDataToSavePath:(ZXUser*)userData{
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userData];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:USER_BASIC_INFO_IN_LOCAL];
        [defaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"has_change_profile_by_wexin" object:nil];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
        
        if (self = [super init]) {
                self.wechatId = [aDecoder decodeObjectForKey:@"wechatId"];
                self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
                self.signature = [aDecoder decodeObjectForKey:@"signature"];
                self.name = [aDecoder decodeObjectForKey:@"name"];
                self.phone = [aDecoder decodeObjectForKey:@"phone"];
                self.gender = [aDecoder decodeObjectForKey:@"gender"];
                self.title = [aDecoder decodeObjectForKey:@"title"];
                self.company = [aDecoder decodeObjectForKey:@"company"];
                self.address = [aDecoder decodeObjectForKey:@"address"];
                self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        }
        
        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeObject:wechatId forKey:@"wechatId"];
        [aCoder encodeObject:nickName forKey:@"nickName"];
        [aCoder encodeObject:signature forKey:@"signature"];
        [aCoder encodeObject:name forKey:@"name"];
        [aCoder encodeObject:phone forKey:@"phone"];
        [aCoder encodeObject:gender forKey:@"gender"];
        [aCoder encodeObject:title forKey:@"title"];
        [aCoder encodeObject:company forKey:@"company"];
        [aCoder encodeObject:address forKey:@"address"];
        [aCoder encodeObject:avatar forKey:@"avatar"];
}

@end
