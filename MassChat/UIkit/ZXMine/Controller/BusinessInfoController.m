//
//  BusinessInfoController.m
//  MassChat
//
//  Created by wsli on 2017/9/9.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "BusinessInfoController.h"
#import "ZXUser.h"
@interface BusinessInfoController ()<UITextFieldDelegate>{
        ZXUser*                 _currentUserInfo;
}
@end

@implementation BusinessInfoController

- (void)viewDidLoad {
        [super viewDidLoad];
        
        _currentUserInfo = [ZXUser loadSelfProfile];
        
        _company.text = _currentUserInfo.company;
        _phone.text = _currentUserInfo.phone;
        _name.text = _currentUserInfo.name;
        _titleOfCompany.text = _currentUserInfo.title;
        _address.text = _currentUserInfo.address;
        
        _company.delegate = self;
        _phone.delegate = self;
        _name.delegate = self;
        _titleOfCompany.delegate = self;
        _address.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated{
        [super viewDidDisappear:animated];
        [ZXUser syncDataToSavePath:_currentUserInfo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
        if (textField == _company || textField == _phone
            || textField == _name || textField == _titleOfCompany
            || textField == _address) {
                [textField resignFirstResponder];
                _currentUserInfo.company = _company.text;
                _currentUserInfo.phone = _phone.text;
                _currentUserInfo.name = _name.text;
                _currentUserInfo.title = _titleOfCompany.text;
                _currentUserInfo.address = _address.text;
                return NO;
        }
        return YES;
}

@end
