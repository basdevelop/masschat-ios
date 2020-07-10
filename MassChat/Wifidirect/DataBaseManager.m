//
//  DataBaseManager.m
//  MassChat
//
//  Created by wsli on 2017/8/28.
//  Copyright © 2017年 众信. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h" 
#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif


#define DATABASE_STRUCTURE_VERSION_KEY          @"database_structure_version_key"

#define CURRENT_DATABASE_VERSION                1

@interface DataBaseManager(){
        FMDatabaseQueue*        _dataBaseQueue;
        NSString*               _databasePath;
}
@end

@implementation DataBaseManager

static  DataBaseManager  *_instance = nil;
+ (id)getInstance {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
                _instance = [[self alloc] init];
        });
        return _instance;
}

-(id) init{
        self = [super init];
        if (self){
                NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                _databasePath = [documents stringByAppendingPathComponent:@"masschat.db"];
                _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
                
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger database_version = [defaults integerForKey:DATABASE_STRUCTURE_VERSION_KEY];
                if (CURRENT_DATABASE_VERSION != database_version){
                        [defaults setInteger:CURRENT_DATABASE_VERSION forKey:DATABASE_STRUCTURE_VERSION_KEY];
                        [self dropOldVersionTables];
                }
                
                if (![self initSystemTables]){
                        return nil;
                }
                
                [_dataBaseQueue close];
        }
        
        return self;
}

-(BOOL) dropOldVersionTables{
        
        BOOL __block success = false;
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                success = [db executeUpdate:@"drop table if exists message"];
                if (!success){
                        NSLog(@"Error 清空消息表失败 error=%@", [db lastErrorMessage]);
                };
                
                success = [db executeUpdate:@"drop table if exists friends"];
                if (!success){
                        NSLog(@"Error 清空好友表失败 error=%@", [db lastErrorMessage]);
                };

        }];
        
        return success;
}

-(BOOL) initSystemTables{
        
        NSString* sql_create_message = @"create table if not exists message (id integer primary key autoincrement, "
        " peerName TEXT, content TEXT, type INTEGER, isIn INTEGER,"
        " createTime REAL, binData BLOB, status INTEGER);";
        
         NSString* sql_create_friends = @"create table if not exists friends (id integer primary key autoincrement, "
        " peerName TEXT, name TEXT, gender TEXT, title TEXT, company TEXT, address TEXT, "
        " unreadNo INTEGER, updateTime REAL, lastMessage TEXT, avatar BLOB);";
        
        NSString* sql_create_trans_record = @"create table if not exists transRecrd (id integer primary key autoincrement, "
        " senderPeerName TEXT, receiverPeerName TEXT,  createTime REAL, fileName TEXT, "
        " fileSize TEXT, directionForMe INTEGER);";
        
        NSString* sql_create_music = @"create table if not exists music (id integer primary key autoincrement, "
        " fileName TEXT, filePath TEXT, createTime REAL);";
        
        
        BOOL __block success = false;
       
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                success = [db executeUpdate:sql_create_message];
                if (!success){
                        NSLog(@"Error 创建消息表失败 sql = %@ error=%@", sql_create_message, [db lastErrorMessage]);
                }
                
                success = [db executeUpdate:sql_create_friends];
                if (!success){
                        NSLog(@"Error 创建好友表失败 sql = %@ error=%@", sql_create_friends, [db lastErrorMessage]);
                }
                
                success = [db executeUpdate:sql_create_trans_record];
                if (!success){
                        NSLog(@"Error 创建文件传输历史记录失败 sql = %@ error=%@", sql_create_trans_record, [db lastErrorMessage]);
                }
                
                success = [db executeUpdate:sql_create_music];
                if (!success){
                        NSLog(@"Error 创建音乐文件记录失败 sql = %@ error=%@", sql_create_music, [db lastErrorMessage]);
                }
        }];
        
        return success;
}


-(NSMutableArray*)loadHistoryMessages:(NSString*)peerName withLastId:(NSInteger*) lastMessageId{
        
        NSMutableArray* result  = [NSMutableArray new];
        
        NSString* sql = @"select * from message where id < %ld and peerName=%@ order by id desc limit 30;";
        long __block lastest_message_id = *lastMessageId;
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {

                FMResultSet *result_set = [db executeQueryWithFormat:sql, (long)*lastMessageId, peerName];
               
                while ([result_set next]) {
                        MessageBean* msg_bean = [MessageBean new];
                        
                        [msg_bean setText:[result_set stringForColumn:@"content"]];
                        [msg_bean setType:(MessageBeanType)[result_set intForColumn:@"type"]];
                        [msg_bean setTime:[result_set dateForColumn:@"createTime"]];
                        [msg_bean setInMsg:(Boolean)[result_set intForColumn:@"isIn"]];
                        [msg_bean setBinData:[result_set dataForColumn:@"binData"]];
                        [msg_bean setStatus:(Boolean)[result_set intForColumn:@"status"]];
                        
                        [result insertObject:msg_bean atIndex:0];
                        lastest_message_id = [result_set longForColumn:@"id"];
                }
                
                 [result_set close];
        }];
        
        *lastMessageId = lastest_message_id;
        
       
        [_dataBaseQueue close];
        
        return result;
}

-(void)saveMessage:(MessageBean*)msg withPeerName:(NSString*)peerName{
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
         [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
                 NSString* sql = @"insert into message(peerName, content, type, isIn,"
                 " createTime, binData, status) values(?, ?, ?, ?, ?, ?, ?)";
        
                 BOOL success = [db executeUpdate:sql, peerName, msg.text, msg.type, [NSNumber numberWithBool:msg.inMsg],
                                        msg.time, msg.binData, [NSNumber numberWithBool:msg.status]];
        
                 if (!success){
                        NSLog(@"Error 插入聊天记录数据错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                 }
                 
                 [db executeUpdate:@"update friends set lastMessage=? where peerName=?",  msg.text, peerName];
        
         }];
        
        [_dataBaseQueue close];
}

-(NSMutableDictionary*) loadFriendsHasChatHistory{
        NSMutableDictionary* history_friends = [NSMutableDictionary new];
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
                NSString* sql = @"select * from friends order by updateTime desc";
        
                FMResultSet *result_set = [db executeQuery:sql];
        
                while ([result_set next]){
                 
                         FriendNearBy* friend_bean = [FriendNearBy new];
                         
                         [friend_bean setName:[result_set stringForColumn:@"name"]];
                         [friend_bean setGender:[result_set stringForColumn:@"gender"]];
                         [friend_bean setTitle:[result_set stringForColumn:@"title"]];
                         [friend_bean setCompany:[result_set stringForColumn:@"company"]];
                         [friend_bean setAddress:[result_set stringForColumn:@"address"]];
                         [friend_bean setUpdateTime:[result_set dateForColumn:@"updateTime"]];
                         [friend_bean setLastMessage:[result_set stringForColumn:@"lastMessage"]];
                         
                         NSString* peer_name = [result_set stringForColumn:@"peerName"];
                         [friend_bean setPeerName:peer_name];
                        NSData* image_data = [result_set dataForColumn:@"avatar"];
                        [friend_bean setAvatar:[UIImage imageWithData:image_data]];
                        
                         [history_friends setObject:friend_bean forKey:peer_name];
                }
        
                [result_set close];
                
                }];
        
        [_dataBaseQueue close];
        
        return history_friends;
}

-(FriendNearBy*)getFrinedByPeerName:(NSString*)peerName{
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        
        FriendNearBy* __block bean = nil;
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"select * from friends where peerName=?";
                
                FMResultSet *result_set = [db executeQuery:sql, peerName];
                
                while ([result_set next]){
                        
                        FriendNearBy* friend_bean = [FriendNearBy new];
                        
                        [friend_bean setName:[result_set stringForColumn:@"name"]];
                        [friend_bean setGender:[result_set stringForColumn:@"gender"]];
                        [friend_bean setTitle:[result_set stringForColumn:@"title"]];
                        [friend_bean setCompany:[result_set stringForColumn:@"company"]];
                        [friend_bean setAddress:[result_set stringForColumn:@"address"]];
                        [friend_bean setUpdateTime:[result_set dateForColumn:@"updateTime"]];
                        [friend_bean setLastMessage:[result_set stringForColumn:@"lastMessage"]];
                        NSData* image_data = [result_set dataForColumn:@"avatar"];
                        [friend_bean setAvatar:[UIImage imageWithData:image_data]];
                        
                        bean = friend_bean;
                        break;
                }
                
                [result_set close];
                
        }];
        
        [_dataBaseQueue close];
        
        return bean;
        
}

-(void)updateFriendInfo:(FriendNearBy*)friendBean{
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
         [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
                NSString* sql = @"select * from friends where peerName=?";
                
                FMResultSet *result_set = [db executeQuery:sql, friendBean.peerId.displayName];
                
                Boolean has_this_friend = false;
                while ([result_set next]){
                        has_this_friend = true;
                        break;
                }
                
                if (has_this_friend){
                        sql = @"update friends set name=?, gender=?, title=?, company=?, "
                        "address=?, updateTime=?  where peerName=?";
                        
                }else{
                        sql = @"insert into friends(name, gender, title, company, address, "
                        "updateTime, peerName) values (?,?,?,?,?,?,?)";
                }
                
                BOOL success = [db executeUpdate:sql, friendBean.name, friendBean.gender,
                                friendBean.title,  friendBean.company, friendBean.address,
                                [NSDate date], friendBean.peerId.displayName];
                
                if (!success){
                        NSLog(@"Error 更新好友信息错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
                
                [result_set close];
        
         }];
        
        [_dataBaseQueue close];
}

-(void)removeFriendByPeerName:(NSString*)peerName{
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString* sql = @"delete from friends where peerName=?";
                
                BOOL success = [db executeUpdate:sql, peerName];
                
                if (!success){
                        NSLog(@"Error 删除好友信息错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
        }];
        
        
        [_dataBaseQueue close];
}



-(UIImage*)loadAvatarByPeerName:(NSString*)peerName{
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        
        UIImage* __block image = nil;
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"select avatar from friends where peerName=?";
                
                FMResultSet *result_set = [db executeQuery:sql, peerName];
                
                while ([result_set next]){
                        
                        NSData * data = [result_set dataForColumn:@"avatar"];
                        image = [UIImage imageWithData:data];
                        
                        break;
                }
                
                [result_set close];
                
        }];
        
        [_dataBaseQueue close];
        
        return image;
}

-(void)updateFriendAvatar:(NSData*)data withPeerName:(NSString*)peerName{
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString* sql = @"update friends set avatar = ? where peerName=?";
                
                BOOL success = [db executeUpdate:sql, data, peerName];
                
                if (!success){
                        NSLog(@"Error 更新好友信息错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
        }];
        [_dataBaseQueue close];
}


-(NSMutableArray*)loadTransRecord:(NSInteger*) lastMessageId{
        
        NSMutableArray* history_record = [NSMutableArray new];

        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        long __block lastest_message_id = *lastMessageId;
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"select * from transRecrd where id < %ld order by id desc limit 30;";
                
                FMResultSet *result_set = [db executeQueryWithFormat:sql, (long)*lastMessageId];
                
                while ([result_set next]){
                        
                        TransPortRecord* record_bean = [TransPortRecord new];
                        [record_bean setRecordId:[result_set longForColumn:@"id"]];
                        [record_bean setSenderPeerName:[result_set stringForColumn:@"senderPeerName"]];
                        [record_bean setReceiverPeerName:[result_set stringForColumn:@"receiverPeerName"]];
                        [record_bean setCreateTime:[result_set dateForColumn:@"createTime"]];
                        [record_bean setFileName:[result_set stringForColumn:@"fileName"]];
                        [record_bean setFileSize:[result_set stringForColumn:@"fileSize"]];
                        [record_bean setDirectionForMe:[result_set boolForColumn:@"directionForMe"]];
                        
                       
                        [history_record addObject:record_bean];
                        lastest_message_id = [result_set longForColumn:@"id"];
                }
                
                [result_set close];
                
        }];
        
        *lastMessageId = lastest_message_id;
        
        [_dataBaseQueue close];
        
        return history_record;
}


-(void)saveTransRecord:(TransPortRecord*)record{
        
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"insert into transRecrd(senderPeerName, receiverPeerName, "
                " createTime, fileName, fileSize, directionForMe) values (?, ?, ?, ?, ?, ?)";
                
                
                BOOL success = [db executeUpdate:sql, record.senderPeerName, record.receiverPeerName,
                                record.createTime,  record.fileName, record.fileSize, [NSNumber numberWithBool: record.directionForMe]];
                
                if (!success){
                        NSLog(@"Error 更新文件传输信息错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }                
        }];
        
        [_dataBaseQueue close];
}

-(void)removeTransRecord:(NSInteger)recordId{
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"delete from transRecrd where id = ?";
                
                
                BOOL success = [db executeUpdate:sql,  [NSNumber numberWithLong: recordId]];
                
                if (!success){
                        NSLog(@"Error 删除文件传输信息错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
        }];
        
        [_dataBaseQueue close];
}


-(void)saveMusic:(MusicItem*)musicItem{
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"insert into music(fileName, filePath, createTime) values (?, ?, ?)";
                
                
                BOOL success = [db executeUpdate:sql, musicItem.fileName, [musicItem.fileUrl absoluteString],
                                musicItem.createTime];
                
                if (!success){
                        NSLog(@"Error 创建音乐文件记录失败 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
        }];
        
        [_dataBaseQueue close];
}

-(NSMutableArray*)loadSavedMusic:(NSInteger*) lastMessageId{
        NSMutableArray* music_list = [NSMutableArray new];
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath flags:SQLITE_OPEN_READONLY];
        long __block lastest_message_id = *lastMessageId;
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"select * from music where id < %ld order by id desc limit 30;";
                
                FMResultSet *result_set = [db executeQueryWithFormat:sql, (long)*lastMessageId];
                
                while ([result_set next]){
                        
                        MusicItem* music_bean = [MusicItem new];
                        [music_bean setMusicId:[result_set longForColumn:@"id"]];
                        [music_bean setFileName:[result_set stringForColumn:@"fileName"]];
                        [music_bean setFileUrl:[NSURL URLWithString:[result_set stringForColumn:@"filePath"]]];
                        [music_bean setCreateTime:[result_set dateForColumn:@"createTime"]];
                        
                        
                        [music_list addObject:music_bean];
                        lastest_message_id = [result_set longForColumn:@"id"];
                }
                
                [result_set close];
                
        }];
        
        *lastMessageId = lastest_message_id;
        
        [_dataBaseQueue close];
        
        return music_list;
}


-(void)removeMusicItem:(NSInteger)musicItemId{
        
        _dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databasePath];
        
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
                
                NSString* sql = @"delete from music where id = ?";
                
                
                BOOL success = [db executeUpdate:sql,  [NSNumber numberWithLong: musicItemId]];
                
                if (!success){
                        NSLog(@"Error 删除音乐文件记录错误 sql = %@ error=%@", sql, [db lastErrorMessage]);
                }
        }];
        
        [_dataBaseQueue close];
}


@end
