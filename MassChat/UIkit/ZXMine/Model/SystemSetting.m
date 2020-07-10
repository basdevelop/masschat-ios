//
//  SystemSetting.m
//  MassChat
//
//  Created by wsli on 2017/9/9.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "SystemSetting.h"
#define SYSTEM_SETTING_KEY      @"SYSTEM_SETTING_KEY"

@implementation SystemSetting

@synthesize soundsSwitch, businessInfoSwitch;

static  SystemSetting  *_instance = nil;
+ (id)getInstance {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                _instance = [[self alloc] init];
        });
        return _instance;
}

-(id)init{
        if (self = [super init]){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [defaults dataForKey:SYSTEM_SETTING_KEY];
                if (nil == data){
                        self.soundsSwitch = YES;
                        self.businessInfoSwitch = NO;
                }else{
                        self = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
        }
        return self;
}
-(void)sync{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:SYSTEM_SETTING_KEY];
        [defaults synchronize];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
        
        if (self = [super init]) {
                self.soundsSwitch = [aDecoder decodeBoolForKey:@"soundsSwitch"];
                self.businessInfoSwitch = [aDecoder decodeBoolForKey:@"businessInfoSwitch"];
        }
        
        return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [aCoder encodeBool:soundsSwitch  forKey:@"soundsSwitch"];
        [aCoder encodeBool:businessInfoSwitch forKey:@"businessInfoSwitch"];
}

@end
