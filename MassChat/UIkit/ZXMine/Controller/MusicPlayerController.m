//
//  MusicPlayerController.m
//  MassChat
//
//  Created by wsli on 2017/9/7.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "MusicPlayerController.h"
#import "DataBaseManager.h"
#import "MusicItemCell.h"
#import "MusicItem.h"

@interface MusicPlayerController (){
        NSMutableArray*         _musicList;
        NSInteger               _lastMusicIdToShow;
}

@end

@implementation MusicPlayerController

- (void)viewDidLoad {
        [super viewDidLoad];
        _lastMusicIdToShow = LONG_MAX;
        self.title = @"音乐";
        _musicList = [[DataBaseManager getInstance] loadSavedMusic:&_lastMusicIdToShow];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"MusicItemCell"
                                                   bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MusicItemCellID"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        MusicItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicItemCellID" forIndexPath:indexPath];
    
        MusicItem* music_item = [_musicList objectAtIndex:indexPath.row];
        
        [cell renderByMusicItem:music_item];
    
        return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
        return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
        
        MusicItem* record = [_musicList objectAtIndex:indexPath.row];
        
        [[DataBaseManager getInstance] removeMusicItem:[record musicId]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError* error = nil;
        if ([fileManager removeItemAtURL:[record fileUrl] error:&error] != YES){
                NSLog(@"删除文件失败: %@", error);
        }
        
        [_musicList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        
}

@end
