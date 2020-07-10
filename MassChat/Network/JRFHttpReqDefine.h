//
//  NetWorkManager.h
//  EDQFirm
//
//  Created by 聚财村 on 16/6/2.
//  Copyright © 2016年 e贷圈企业版. All rights reserved.
//

#ifndef DAX_JRFHttpReqDefine_h
#define DAX_JRFHttpReqDefine_h


#define DEFAULT_BASEURL @"https://sendbox.jucaicun.com/0f1406c0500da724f391a8341da2da23/"
//http://e.jucaicun.com/mydata2/menu_list.json
//https://sendbox.jucaicun.com/0f1406c0500da724f391a8341da2da23/
#define mShareUrl  @""
 

/*图片服务器*/
#define KXF_UPDATEIMAGEURL @"" //上传图片的服务器


#define mMenuList @"mydata2/menu_list.json?" //正式单列表
#define mSendSms @"ajax/client/apply?" //获取验证码
#define mSendSmsAgain @"ajax/client/sendSmsAgain?" //再次发送验证码

#define mAppApply @"ajax/client/appApply?"//单子详情
#define mBillDraft @"app/employee_fill/fill_update_open?"//单子详情

#define mEDQLogin @"app/employee_basicfunc/signin?" //登录
#define mEDQUpdatePwd @"app/employee_basicfunc/changepass?" //修改密码

#define mSquareList @"mydata2/square_list.json?" //登录


#endif
