//
//  AppDelegate.m
//  EDQFirm
//
//  Created by 聚财村 on 16/6/1.
//  Copyright © 2016年 e贷圈企业版. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  该类可作为项目中数据模型（用于tableviewcell现实）基类的基类，来缓存cell高度等
 */
@interface JRFBaseCellDataModal : NSObject
//识别cell类型
@property int nType;
//缓存cell高度
@property float nHeight;
//来标识该cell是否可以点击
@property BOOL bCanThouch;

@end


/**
 *  该类作为项目中数据模型的基类使用
 */
@interface JRFBaseObject : JRFBaseCellDataModal
/**
 *  根据传入的dict返回相应的数据模型对象，子类中重写
 *
 *  @param theDictionary 传入的dict类型数据
 *
 *  @return 返回数据模型对象
 */
- (id)initWithDictionary:(NSDictionary *)theDictionary;
- (NSString *)safeStrValue:(id)value replace:(NSString *)replaceStr;
- (NSString *)safeStrValueWithKey:(NSString *)key replace:(NSString *)replaceStr;
- (NSNumber *)safeNumValue:(id)value replace:(NSNumber *)replaceNum;
- (NSNumber *)safeNumValueWithKey:(NSString *)key replace:(NSNumber *)replaceNum;
@end
//*****************************获取目标格式数据的方法*************************

//从一个字典中根据key获取一个对象
id objGetFromDict(NSDictionary *theDictionary, NSString *key);

//从一个字典中根据key获取一个字符串
NSString *strGetFromDict(NSDictionary *theDictionary, NSString *key);

//从一个字典中根据key获取一个number
NSNumber *numGetFromDict(NSDictionary *theDictionary, NSString *key);

//从一个字典中根据key获取一个数组列表
NSArray *arrGetFromDict(NSDictionary *theDictionary, NSString *key);

//从一个字典中根据key获取一个字典
NSDictionary *dictGetFromDict(NSDictionary *theDictionary, NSString *key);


//从一个数组中根据index获取一个对象
id objGetFromArray(NSArray *theArray, int index);

//从一个数组中根据index获取一个字符串
NSString *strGetFromArray(NSArray *theArray, int index);

//从一个数组中根据index获取一个number
NSNumber *numGetFromArray(NSArray *theArray, int index);

//从一个数组中根据index获取一个数组列表
NSArray *arrGetFromArray(NSArray *theArray, int index);

//从一个数组中根据index获取一个字典
NSDictionary *dictGetFromArray(NSArray *theArray, int index);


