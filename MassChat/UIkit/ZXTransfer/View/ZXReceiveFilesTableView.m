//
//  ZXReceiveFilesTableView.m
//  ZX
//
//  Created by 许李超 on 17/7/31.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "ZXReceiveFilesTableView.h"

@interface ZXReceiveFilesTableView ()<UITableViewDelegate,UITableViewDataSource>

@end
static NSString * const cellID = @"indentifier";
@implementation ZXReceiveFilesTableView


- (instancetype)initWithFrame:(CGRect)frame
{
        self = [super initWithFrame:frame];
        if (self) {
                self.delegate = self;
                self.dataSource = self;
        }
        return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.textLabel.text = @"T1 YangLaoshi";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
