//
//  AppDelegate.m
//  EDQFirm
//
//  Created by 聚财村 on 16/6/1.
//  Copyright © 2016年 e贷圈企业版. All rights reserved.
//

#import "JCCUtils.h"

@implementation JCCUtils

+ (id)sharedInstance {
    static JCCUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)showProgressHud:(UIView *)inView withMessage:(NSString *)message {
                
        [self hideProgressHud];
        if (!HUD) {
                HUD = [MBProgressHUD showHUDAddedTo:inView animated:YES];
                HUD.label.text = message;
                [inView addSubview:HUD];
        }
}
- (void)hideProgressHud {
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}
- (void)showProgressHudAndHideDelay:(NSTimeInterval)delay inView:(UIView *)inView withMessage:(NSString *)message {
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:inView animated:YES];
        HUD.detailsLabel.text = message;
        HUD.mode = MBProgressHUDModeText;
        [inView addSubview:HUD];
        [self performSelector:@selector(hideDelayed) withObject:nil afterDelay:delay];
    }
}
- (void)hideDelayed {
    if (HUD) {
        [HUD hideAnimated:YES];
        [HUD removeFromSuperview];
        HUD = nil;
        
    }
}

- (void)save:(id)obj toFile:(NSString *)fileName {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    if ([NSKeyedArchiver archiveRootObject:obj toFile:path]) {
    }
}
- (id)query:(NSString *)fileName {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (void)removeFile:(NSString *)fileName {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

-(void)graphicsImage:(UIImageView *)image{
        //开始对imageView进行画图
        UIGraphicsBeginImageContextWithOptions(image.bounds.size, NO, [UIScreen mainScreen].scale);
        //使用贝塞尔曲线画出一个圆形图
        [[UIBezierPath bezierPathWithRoundedRect:image.bounds cornerRadius:image.frame.size.width] addClip];
        [image drawRect:image.bounds];
        
        image.image = UIGraphicsGetImageFromCurrentImageContext();
        //结束画图
        UIGraphicsEndImageContext();
}



-(BOOL)checkPhotoLibAutherization:(UIViewController*) parentVC{
        PHAuthorizationStatus ph_status = [PHPhotoLibrary authorizationStatus];
        if (ph_status == PHAuthorizationStatusRestricted
            || ph_status == PHAuthorizationStatusDenied){
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 照片 - 众讯] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"]];
                }];
                
                [alertC addAction:alertA];
                
                
                UIAlertAction *alertB = [UIAlertAction actionWithTitle:@"放弃" style:(UIAlertActionStyleDefault) handler:nil];
                
                [alertC addAction:alertB];
                
                [parentVC presentViewController:alertC animated:YES completion:nil];
                return NO;
        }
        if (PHAuthorizationStatusNotDetermined == ph_status){
                PHAuthorizationStatus __block grant_result = NO;
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus __status__) {
                        grant_result = __status__;
                }];
                
                ph_status = grant_result;
        }
        
        return ph_status == PHAuthorizationStatusAuthorized;
}


-(BOOL)checkCameraAutherization:(UIViewController*) parentVC{
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (nil == device) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
                
                [alertC addAction:alertA];
                [parentVC presentViewController:alertC animated:YES completion:nil];
                return NO;
        }
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
                
                BOOL __block grant_result = NO;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        grant_result = granted;
                }];
                
                return grant_result;
                
        } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
                
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - 众讯] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
                }];
                
                [alertC addAction:alertA];
                
                
                UIAlertAction *alertB = [UIAlertAction actionWithTitle:@"放弃" style:(UIAlertActionStyleDefault) handler:nil];
                
                [alertC addAction:alertB];
                
                [parentVC presentViewController:alertC animated:YES completion:nil];
                return NO;
        }
        
        return status == AVAuthorizationStatusAuthorized;
}

@end
