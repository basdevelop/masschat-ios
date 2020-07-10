#import "JRFBaseObject.h"
#define OBJECT_SAVEVALUE_ERROR @"对象格式错误：[对象格式 %@]/[目标格式 %@]/[默认返回 %@]"
#define OBJECT_FORMAT_ERROR  @"对象格式错误: [对象格式 %@]/[目标格式 %@]"
#define ARRAY_INDEXOUT       @"越界：[index %d 超过了指定数组总大小 %d]"

@implementation JRFBaseCellDataModal
@synthesize nHeight, nType, bCanThouch;
- (void)dealloc {
#if __has_feature(objc_arc)
#else
    [super dealloc];
#endif
}
@end

@interface JRFBaseObject ()

@property (strong, nonatomic) NSDictionary *dict;
@end
@implementation JRFBaseObject

- (id)initWithDictionary:(NSDictionary *)theDictionary {
    if (self = [super init]) {
        if (!_dict) {
            _dict = [NSDictionary dictionaryWithDictionary:theDictionary];
        } else {
            self.dict = theDictionary;
        }
    }
    return self;
}
- (NSString *)safeStrValue:(id)value replace:(NSString *)replaceStr {
//    if (!value) {
//        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSString class], replaceStr);
//        return replaceStr;
//    
//    }
//    if (value == [NSNull null]) {
//        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSString class], replaceStr);
//        return replaceStr;
//    }
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"<null>"] || [value isEqualToString:@"(null)"] || [value isEqualToString:@"null"] || [value isEqualToString:@""]) {
            return replaceStr;
        }
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", value];
    }
//        else {
//        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSString class], replaceStr);
        return replaceStr;
//    }
}
- (NSString *)safeStrValueWithKey:(NSString *)key replace:(NSString *)replaceStr {
    return [self safeStrValue:[self.dict objectForKey:key] replace:replaceStr];
}
- (NSNumber *)safeNumValue:(id)value replace:(NSNumber *)replaceNum {
    //传入的值为空
    if (!value) {
        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSNumber class], replaceNum);
        return replaceNum;
    }
    if (value == [NSNull null]) {
        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSNumber class], replaceNum);
        return replaceNum;
    }
    //传入的值为字符串
    if ([value isKindOfClass:[NSString class]]) {
        //讲字符串转化成number，若能成功直接返回，否则返回默认值
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        id obj = [formatter numberFromString:value];
        mRelease(formatter);
        if (obj) {
            return obj;
        } else {
            NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSNumber class], replaceNum);
            return replaceNum;
        }
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    } else {
        NSLog(OBJECT_SAVEVALUE_ERROR, [value class], [NSNumber class], replaceNum);
        return replaceNum;
    }
}

- (NSNumber *)safeNumValueWithKey:(NSString *)key replace:(NSNumber *)replaceNum {
    return [self safeNumValue:[self.dict objectForKey:key] replace:replaceNum];
}
@end

//验证对象是否正确
BOOL isValidateObj(id obj, Class class) {
    if (obj) {
        if (!class) {
            return YES;
        }
        if (class == [NSString class] && [obj isKindOfClass:[NSString class]]) {
            return YES;
        } else if (class == [NSMutableString class] && [obj isKindOfClass:[NSMutableString class]]) {
            return YES;
        } else if (class == [NSNumber class] && [obj isKindOfClass:[NSNumber class]]) {
            return YES;
        } else if (class == [NSArray class] && [obj isKindOfClass:[NSArray class]]) {
            return YES;
        } else if (class == [NSMutableArray class] && [obj isKindOfClass:[NSMutableArray class]]) {
            return YES;
        } else if (class == [NSDictionary class] && [obj isKindOfClass:[NSDictionary class]]) {
            return YES;
        } else if (class == [NSMutableDictionary class] && [obj isKindOfClass:[NSMutableDictionary class]]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

id aObjGetFromDict(NSDictionary *theDictionary, NSString *key, Class class) {
    if (!theDictionary || !key || [[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return nil;
    }
    id obj = [theDictionary objectForKey:key];
    //验证对象以及格式是否正确，若正确返回该对象否则返回nil并给出提示
    if (isValidateObj(obj, class)) {
        return obj;
    } else {
        NSLog(OBJECT_FORMAT_ERROR, [obj class], class);
    }
    return nil;
}

id aObjGetFromArray(NSArray *theArray, int index, Class class) {
    if (!theArray) {
        return nil;
    }
    if (index >= [theArray count]) {
        NSLog(ARRAY_INDEXOUT, index, (int)[theArray count]);
        return nil;
    }
    id obj = [theArray objectAtIndex:index];
    //验证对象以及格式是否正确，若正确返回该对象否则返回nil并给出提示
    if (isValidateObj(obj, class)) {
        return obj;
    } else {
        NSLog(OBJECT_FORMAT_ERROR, [obj class], class);
    }
    return nil;
}


//字典相关
id objGetFromDict(NSDictionary *theDictionary, NSString *key) {
    return aObjGetFromDict(theDictionary, key, nil);
}

NSString *strGetFromDict(NSDictionary *theDictionary, NSString *key) {
    return aObjGetFromDict(theDictionary, key, [NSString class]);
}

NSNumber *numGetFromDict(NSDictionary *theDictionary, NSString *key) {
    return aObjGetFromDict(theDictionary, key, [NSNumber class]);
}

NSArray *arrGetFromDict(NSDictionary *theDictionary, NSString *key) {
    return aObjGetFromDict(theDictionary, key, [NSArray class]);
}

NSDictionary *dictGetFromDict(NSDictionary *theDictionary, NSString *key) {
    return aObjGetFromDict(theDictionary, key, [NSDictionary class]);
}
//数组相关
id objGetFromArray(NSArray *theArray, int index) {
    return aObjGetFromArray(theArray, index, nil);
}

NSString *strGetFromArray(NSArray *theArray, int index) {
    return aObjGetFromArray(theArray, index, [NSString class]);
}

NSNumber *numGetFromArray(NSArray *theArray, int index) {
    return aObjGetFromArray(theArray, index, [NSNumber class]);
}

NSArray *arrGetFromArray(NSArray *theArray, int index) {
    return aObjGetFromArray(theArray, index, [NSArray class]);
}

NSDictionary *dictGetFromArray(NSArray *theArray, int index) {
    return aObjGetFromArray(theArray, index, [NSDictionary class]);
}

