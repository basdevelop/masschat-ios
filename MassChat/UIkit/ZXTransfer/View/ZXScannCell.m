#import "ZXScannCell.h"
#import "SGQRCode.h"
#import "SGQRCodeScanningVC.h"
#import "WifiDirectManager.h"
#import "FileTransferManager.h"
#import "ZXTransferViewController.h"
#import "QRCodeItemToSend.h"
#import "NSData+MD5.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ZXScannCell()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, MPMediaPickerControllerDelegate>{
        MBProgressHUD*  _progressHud;
}

@property (weak, nonatomic) ZXTransferViewController* parentController;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (nonatomic, assign) NSInteger type;

@property (strong, nonatomic)UIImagePickerController* imagePickerController;
@end


@implementation ZXScannCell

- (void)awakeFromNib {
        [super awakeFromNib];
        _codeImage.hidden = YES;
        
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
}


-(void)cellWithSegmentType:(NSInteger)type  withParentCtl:(ZXTransferViewController*)parentController{
        self.type = type;
        self.parentController = parentController;
        if (type == 1) {
            _stateLabel.text = @"点击生成二维码";
        }
}

- (IBAction)scanBtn:(id)sender {
        if (self.type == 1) {
                [self showImageOrAudioSelection];
        }else if (self.type == 0){
                [self scannBarCodeToLoadFile];
        }
}


#pragma mark - 扫描二维码
-(void)scannBarCodeToLoadFile{
        if (![[JCCUtils sharedInstance] checkCameraAutherization:self.parentController]){
                return ;
        }
        if (![[JCCUtils sharedInstance] checkPhotoLibAutherization:self.parentController]){
                return;
        }
        
        SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.delegate = self.parentController;
        [self.parentController.navigationController pushViewController:vc animated:YES];
}

-(void) showCamera:(UIAlertAction*) action{
        
        if (![[JCCUtils sharedInstance] checkCameraAutherization:self.parentController]){
                return ;
        }
        
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        
        [self.parentController presentViewController:_imagePickerController animated:YES completion:nil];
}

-(void) showImageAlbum:(UIAlertAction*) action{
        
        if (![[JCCUtils sharedInstance] checkPhotoLibAutherization:self.parentController]){
                return;
        }
        
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
        
        [self.parentController presentViewController:_imagePickerController animated:YES completion:nil];
}
-(void) showMusicLibrary:(UIAlertAction*) action{

        MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
        mpc.delegate = self;
        mpc.prompt =@"请选择您需要共享的音乐";
        mpc.allowsPickingMultipleItems = NO;
        mpc.showsCloudItems =NO;
        mpc.showsItemsWithProtectedAssets = NO;
        [[self.parentController parentViewController] presentViewController:mpc animated:YES completion:^{}];
}

-(void)showImageOrAudioSelection{
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请选择你要传输的文件来源"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancel_action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                              handler:nil];
        
        [alert addAction:cancel_action];
        
        UIAlertAction* camera_action = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                     [self showCamera:action];
                                                             }];
        [alert addAction:camera_action];

        
        UIAlertAction* album_action = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                      [self showImageAlbum:action];
                                                              }];
        [alert addAction:album_action];
        
        UIAlertAction* music_action = [UIAlertAction actionWithTitle:@"音乐库" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                                [self showMusicLibrary:action];
                                                        }];
        [alert addAction:music_action];
        
        
        [self.parentController presentViewController:alert animated:YES completion:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - 访问图库或者摄像头之后的回调函数。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info{
        
        NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
        NSURL* __block url = nil;
        QRCodeItemToSend *qr_code_data = [QRCodeItemToSend new];
        
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
                
                if (@available(iOS 11.0, *)) {
                        
                        url = info[UIImagePickerControllerImageURL];
                        NSString* display_name = [url lastPathComponent];
                        [qr_code_data setFileDisplayName:display_name];
                        NSLog(@"图片ios11临时文件=%@", url);
                        
                } else {
                        UIImage *temp_image = (UIImage *)info[UIImagePickerControllerOriginalImage];
                        NSData *png_data = UIImageJPEGRepresentation(temp_image, 1.0);

                        NSDateFormatter *inFormat = [NSDateFormatter new];
                        [inFormat setDateFormat:@"HH-mm-ss"];
                        NSString *display_name = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];

                        NSString *temp_path = [NSTemporaryDirectory() stringByAppendingPathComponent:display_name];
                        BOOL ret = [png_data writeToFile:temp_path atomically:YES];
                        NSLog(@"图片(%d)临时文件=%@", ret, temp_path);
                        url = [NSURL fileURLWithPath:temp_path];
                        [qr_code_data setFileDisplayName:display_name];
                }
                
        }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
                url = info[UIImagePickerControllerMediaURL];
                NSData *video_data = [NSData dataWithContentsOfURL:url];
                
                NSDateFormatter *inFormat = [NSDateFormatter new];
                [inFormat setDateFormat:@"HH-mm-ss"];
                NSString *display_name = [NSString stringWithFormat:@"video-%@.%@", [inFormat stringFromDate:[NSDate date]], url.pathExtension];
                
                NSString *temp_path = [NSTemporaryDirectory() stringByAppendingPathComponent:display_name];
                BOOL ret = [video_data writeToFile:temp_path atomically:YES];
                
                NSLog(@"视频(%d)临时文件=%@", ret, temp_path);
                url = [NSURL fileURLWithPath:temp_path];
                
                [qr_code_data setFileDisplayName:display_name];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.parentController dismissViewControllerAnimated:YES completion:nil];
                
                [qr_code_data setUrl:url];
                
                NSString* peer_name = [[WifiDirectManager getInstance] mcPeerID].displayName;
                NSString* qr_string = [qr_code_data generateString:peer_name];
                _codeImage.hidden = NO;
                _codeImage.image = [SGQRCodeGenerateManager SG_generateWithDefaultQRCodeData:qr_string
                                                                              imageViewWidth:_codeImage.width];
                
                [qr_code_data setDelegate:self.parentController];
                
                [[FileTransferManager getInstance] setCurrentShowingQRData:qr_code_data];
        });
}

#pragma mark - 选择音乐之后的处理

//当用户选择指定音乐时激发该方法，mediaItemCollection代表用户选择的音乐

- (void)mediaPicker: (MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection*)mediaItemCollection{
        
        NSArray* music_list = [mediaItemCollection items];
        if (nil == music_list || music_list.count == 0){
                return;
        }
        
        MPMediaItem* item = music_list[0];
                
        NSLog(@"%@+++++%@", item.title, item.assetURL);
        
        NSString *display_name = [NSString stringWithFormat:@"%@.m4a", item.title];
        
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:item.assetURL options:nil];
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName: AVAssetExportPresetAppleM4A];
        
        exporter.outputFileType = @"com.apple.m4a-audio";
        NSString *temp_path = [NSTemporaryDirectory() stringByAppendingPathComponent: display_name];
        
        NSLog(@"音乐临时文件=%@", temp_path);
        NSURL* url = [NSURL fileURLWithPath:temp_path];
        exporter.outputURL = url;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:temp_path]) {
                NSError *deleteErr = nil;
                [[NSFileManager defaultManager] removeItemAtPath:temp_path error:&deleteErr];
                if (deleteErr)  {
                        NSLog (@"Can't delete %@: %@", temp_path, deleteErr);
                }
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentController.navigationController.view animated:YES];
        hud.label.text = @"加载中...";
        
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [hud hideAnimated:YES];

                        
                int exportStatus = exporter.status;
                if (AVAssetExportSessionStatusCompleted == exportStatus){
                        
                        QRCodeItemToSend *qr_code_data = [QRCodeItemToSend new];
                        
                        [qr_code_data setFileDisplayName:display_name];
                        
                        [qr_code_data setUrl:url];
                        
                        NSString* peer_name = [[WifiDirectManager getInstance] mcPeerID].displayName;
                        NSString* qr_string = [qr_code_data generateString:peer_name];
                        
                        self->_codeImage.hidden = NO;
                        _codeImage.image = [SGQRCodeGenerateManager SG_generateWithDefaultQRCodeData:qr_string
                                                                                      imageViewWidth:_codeImage.width];
                        
                        [qr_code_data setDelegate:self.parentController];
                        
                        [[FileTransferManager getInstance] setCurrentShowingQRData:qr_code_data];
                }else{
                        [[JCCUtils sharedInstance] showProgressHudAndHideDelay:1
                                inView:self.parentController.navigationController.view
                                                   withMessage:@"到处音乐文件失败"];
                        _codeImage.hidden = YES;
                        _codeImage.image = nil;
                        NSLog (@"导出音乐文件失败: %@", exporter.error);
                }
        });}];
        
       [self.parentController dismissViewControllerAnimated:YES completion:nil];
        
}

//点击取消按钮触发的方法

- (void)mediaPickerDidCancel:(MPMediaPickerController*)mediaPicker{
        
        [self.parentController dismissViewControllerAnimated:YES completion:^{
        }];
        NSLog(@"用户取消了选择");
        
}

@end
