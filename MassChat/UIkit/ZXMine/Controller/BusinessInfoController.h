//
//  BusinessInfoController.h
//  MassChat
//
//  Created by wsli on 2017/9/9.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessInfoController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *company;
@property (weak, nonatomic) IBOutlet UITextField *phone;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *titleOfCompany;
@property (weak, nonatomic) IBOutlet UITextField *address;
 
@end
