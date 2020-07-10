//
//  SGQRCodeScanningVC.h
//  SGQRCodeExample
//
//  Created by kingsic on 17/3/20.
//  Copyright © 2017年 kingsic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGQRCodeScanningDelegate <NSObject>
- (void)getQRStringSuccess:(NSString*) QRString;
- (void)getQRStringFailed;
@end

@interface SGQRCodeScanningVC : UIViewController
@property (nonatomic, strong) id<SGQRCodeScanningDelegate>      delegate;
@end
