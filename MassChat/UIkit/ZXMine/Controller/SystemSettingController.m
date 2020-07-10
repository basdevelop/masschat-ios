//
//  SystemSettingController.m
//  MassChat
//
//  Created by wsli on 2017/9/8.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "SystemSettingController.h"
#import "SystemSetting.h"
#import "ZXUser.h"
#import "JCCUtils.h"

@interface SystemSettingController ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
        ZXUser* _currentUser;
}
@property (strong, nonatomic)UIImagePickerController* imagePickerController;
@end

@implementation SystemSettingController

- (void)viewDidLoad {
        [super viewDidLoad];
        
        
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
        
        _messageNotifierSwitch.onImage = [UIImage imageNamed:@"open_btn"];
        _messageNotifierSwitch.offImage = [UIImage imageNamed:@"close_btn"];
        
        _changeBusinessInfoSwitch.onImage = [UIImage imageNamed:@"open_btn"];
        _changeBusinessInfoSwitch.offImage = [UIImage imageNamed:@"close_btn"];
        
        _messageSoundSwitch.on = [[SystemSetting getInstance] soundsSwitch];
        _openBusinessInfoSwitch.on = [[SystemSetting getInstance] businessInfoSwitch];
        
        _nickName.delegate = self;
        _signature.delegate = self;
        
        _currentUser = [ZXUser loadSelfProfile];
        _nickName.text = _currentUser.nickName;
        _signature.text = _currentUser.signature;
        if (_currentUser.avatar){
                _userAvatar.image = _currentUser.avatar;
                [[JCCUtils sharedInstance] graphicsImage:_userAvatar];
        }
}

-(void)viewDidDisappear:(BOOL)animated{
        [super viewDidDisappear:animated];
        [ZXUser syncDataToSavePath:_currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)changeMessageSounds:(UISwitch*)sender {
        [[SystemSetting getInstance] setSoundsSwitch:sender.on];
        [[SystemSetting getInstance] sync];
}

- (IBAction)changeBusinessInfo:(UISwitch*)sender {
        [[SystemSetting getInstance] setBusinessInfoSwitch:sender.on];
        [[SystemSetting getInstance] sync];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        if (textField == _nickName) {
                [textField resignFirstResponder];
                _currentUser.nickName = _nickName.text;
                return NO;
        }
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
        
        if ([text isEqualToString: @"\n"]) {
                [textView resignFirstResponder];
                _currentUser.signature = _signature.text;
                return NO;
        }
        return YES;
}


-(void) showCamera:(UIAlertAction*) action{
        
        if (![[JCCUtils sharedInstance] checkCameraAutherization:self]){
                return ;
        }
        
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        
        [self presentViewController:_imagePickerController animated:YES completion:nil];
}

-(void) showImageAlbum:(UIAlertAction*) action{
        
        if (![[JCCUtils sharedInstance] checkPhotoLibAutherization:self]){
                return;
        }
        
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        
        [self presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 0 && indexPath.row == 0){
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                               message:@"请选择图片来源"
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
                
                
                [self presentViewController:alert animated:YES completion:nil];
                
        }else{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
}
#pragma mark - 访问图库或者摄像头之后的回调函数。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info{
        
        NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
        
        if (![mediaType isEqualToString:(NSString *)kUTTypeImage]){
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
        }
        _currentUser.avatar = (UIImage *)info[UIImagePickerControllerEditedImage];
        [ZXUser syncDataToSavePath:_currentUser];
        _userAvatar.image = _currentUser.avatar;
        [[JCCUtils sharedInstance] graphicsImage:_userAvatar];
        
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
        [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"用户取消了选择");
        }];
}

@end
