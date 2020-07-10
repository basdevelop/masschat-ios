//
//  IntroducePageViewController.h
//  MassChat
//
//  Created by wsli on 2017/9/29.
//  Copyright © 2017年 众信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroducePageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *introduceImage;
@property (strong, nonatomic) NSString* imageName;

- (IBAction)pushToMainAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *startAppBtn;

@end
