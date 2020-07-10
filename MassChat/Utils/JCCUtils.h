//
//  AppDelegate.m
//  EDQFirm
//
//  Created by 聚财村 on 16/6/1.
//  Copyright © 2016年 e贷圈企业版. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface JCCUtils : NSObject {
    
    MBProgressHUD *HUD;
}

+ (id)sharedInstance;
- (void)showProgressHud:(UIView *)inView withMessage:(NSString *)message;
- (void)hideProgressHud;
- (void)showProgressHudAndHideDelay:(NSTimeInterval)delay inView:(UIView *)inView withMessage:(NSString *)message;

- (void)save:(id)obj toFile:(NSString *)fileName;
- (id)query:(NSString *)fileName;
- (void)removeFile:(NSString *)fileName;

-(void)graphicsImage:(UIImageView *)image;

-(BOOL)checkPhotoLibAutherization:(UIViewController*) parentVC;
-(BOOL)checkCameraAutherization:(UIViewController*) parentVC;

@end
