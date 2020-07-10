//
//  SGQRCodeScanningVC.m
//  SGQRCodeExample
//
//  Created by kingsic on 17/3/20.
//  Copyright © 2017年 kingsic. All rights reserved.
//

#import "SGQRCodeScanningVC.h"
#import "SGQRCode.h"

@interface SGQRCodeScanningVC () <SGQRCodeScanManagerDelegate, SGQRCodeAlbumManagerDelegate>
@property (nonatomic, strong) SGQRCodeScanningView *scanningView;
@end

@implementation SGQRCodeScanningVC

@synthesize delegate;

- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        [self.scanningView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
        [self.scanningView removeTimer];
}

- (void)dealloc {
        NSLog(@"SGQRCodeScanningVC - dealloc");
        [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        [[JCCUtils sharedInstance] hideProgressHud];
        
        self.view.backgroundColor = [UIColor clearColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return_ic"]style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
        
        [leftButton setTintColor:RGBCOLOR(245, 245, 245)];
        self.navigationItem.leftBarButtonItem = leftButton;
        [self.view addSubview:self.scanningView];
        [self setupNavigationBar];
        [self setupQRCodeScanning];
}

-(void)backHome {
        [self.navigationController popViewControllerAnimated:YES];
}

- (SGQRCodeScanningView *)scanningView {
        if (!_scanningView) {
        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:self.view.bounds layer:self.view.layer];
        }
        return _scanningView;
}

- (void)removeScanningView {
        [self.scanningView removeTimer];
        [self.scanningView removeFromSuperview];
        self.scanningView = nil;
}

- (void)setupNavigationBar {
        self.navigationItem.title = @"扫一扫";
}

- (void)setupQRCodeScanning {
        SGQRCodeScanManager *manager = [SGQRCodeScanManager sharedManager];
        NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
        [manager SG_setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
        manager.delegate = self;
}


#pragma mark - - - SGQRCodeAlbumManagerDelegate 扫描本地图片回调方法
- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(SGQRCodeAlbumManager *)albumManager {
        [self.view addSubview:self.scanningView];
}
- (void)QRCodeAlbumManager:(SGQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result {
        if ([result hasPrefix:@"http"]) {
                NSLog(@"QRCodeAlbumManager=%@",result);
        
    } else {
            NSLog(@"QRCodeAlbumManager=%@",result);
    }
}

#pragma mark - - - SGQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(SGQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
        
        if (metadataObjects != nil && metadataObjects.count > 0) {
                [scanManager SG_palySoundName:@"SGQRCode.bundle/sound.caf"];
                [scanManager SG_stopRunning];
                [scanManager SG_videoPreviewLayerRemoveFromSuperlayer];
        
                AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        [self backHome];
                        if (self.delegate){
                                [self.delegate getQRStringSuccess: [obj stringValue]];
                        }
                });

            
        } else {
                NSLog(@"暂未识别出扫描的二维码");
                if (self.delegate){
                        [self.delegate getQRStringFailed];
                }
        }
        
}


@end

