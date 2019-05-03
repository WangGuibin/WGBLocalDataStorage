//
//  WGBLocalDataStorage.m
//  WGBLocalDataStorage
//
//  Created by 王贵彬 on 2019/5/3.
//  Copyright © 2019 王贵彬. All rights reserved.
//

#import "WGBLocalDataStorage.h"
#import <objc/runtime.h>

@implementation WGBCodingObject

- (instancetype)init {
    
    if (self = [super init]) {
        [self checkPropertyConformsToNSCodingProtocol];
    }
    return self;
}

// 检测所有成员变量是否遵循NSCoding协议
- (void)checkPropertyConformsToNSCodingProtocol {
    
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t thisProperty = propertyList[i];
        const char * type = property_getAttributes(thisProperty);
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            
            BOOL isConforms = [typeClass conformsToProtocol:@protocol(NSCoding)];
            if (!isConforms) {
                NSLog(@"未遵循NSCoding协议错误,请查看下面的错误日志👇👇👇");
                NSString *exceptionContent = [NSString stringWithFormat:@"%@ 类中的 %@属性 未遵循NSCoding协议,请手动调整",NSStringFromClass([self class]),typeClassName];
                @throw [NSException exceptionWithName:@"property has not NSCoding Protocol" reason:exceptionContent userInfo:nil];
            }
        }
    }
    free(propertyList);
}

//检测用户写的忽略数组是否含有位置属性名,例如@"name" 写成 @"names" 等,默认会有提示.
- (void)setIgnoreEncodePropertyList:(NSArray<NSString *> *)ignoreEncodePropertyList {
    _ignoreEncodePropertyList = ignoreEncodePropertyList;
    if (!_closeAlertLog) {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:16];
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t *thisProperty = &propertyList[i];
            const char *name = property_getName(*thisProperty);
            NSString *propertyName = [NSString stringWithFormat:@"%s",name];
            [propertyNames addObject:propertyName];
        }
        for (int i = 0; i < _ignoreEncodePropertyList.count; i++) {
            if (![propertyNames containsObject:_ignoreEncodePropertyList[i]]) {
                NSLog(@"%@ 类中未含有需要忽略归档的属性 %@ ,请检查",NSStringFromClass([self class]),_ignoreEncodePropertyList[i]);
            }
        }
        free(propertyList);
    }
}

#pragma mark - 归档与解档

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    @try {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t *thisProperty = &propertyList[i];
            const char *name = property_getName(*thisProperty);
            NSString *propertyName = [NSString stringWithFormat:@"%s",name];
            if (_ignoreEncodePropertyList != nil && [_ignoreEncodePropertyList containsObject:propertyName]) {
                continue;
            }
            id propertyValue = [self valueForKey:propertyName];
            [aCoder encodeObject:propertyValue forKey:propertyName];
        }
        free(propertyList);
    } @catch (NSException *exception) {
        if ([exception.name isEqualToString:@"NSInvalidArgumentException"]) {
            NSLog(@"未遵循NSCoding协议错误,请查看下面的错误日志中的类名👇👇👇");
            @throw exception;
        } else {
            NSLog(@"其他错误,请查看下面的错误日志👇👇👇");
            @throw exception;
        }
    }
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t *thisProperty = &propertyList[i];
            const char *name = property_getName(*thisProperty);
            NSString *propertyName = [NSString stringWithFormat:@"%s",name];
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        free(propertyList);
    }
    return self;
}

@end


#define WGB_DATA_STORAGE_KEY @"WGB_DATA_STORAGE_KEY"

@implementation WGBLocalDataStorage

static WGBLocalDataStorage *_localDataStorage = nil;

+ (instancetype)defaultDataStorage{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_localDataStorage == nil) {
            _localDataStorage = [WGBLocalDataStorage initDataStorage];
        }
    });
    return _localDataStorage;
}

+ (instancetype)initDataStorage{
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey: WGB_DATA_STORAGE_KEY];
    if (data == nil) {
        return [[WGBLocalDataStorage alloc] init];
    } else {
        WGBLocalDataStorage * _localDataStorage = nil;
        @try {
            _localDataStorage = [NSKeyedUnarchiver unarchiveObjectWithData:data]; 
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:@"NSInvalidArgumentException"]) {
                NSLog(@"未遵循NSCoding协议错误,请查看下面的错误日志中的类名👇👇👇");
                @throw exception;
            } else {
                NSLog(@"其他错误,请查看下面的错误日志👇👇👇");
                @throw exception;
            }
        }
        return _localDataStorage;
    }
}

- (void)saveOrUpdateDataStorageResult{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_localDataStorage];
    [[NSUserDefaults standardUserDefaults] setObject: data forKey:WGB_DATA_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteDataStorage{
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t *thisProperty = &propertyList[i];
        const char *name = property_getName(*thisProperty);
        NSString *propertyName = [NSString stringWithFormat:@"%s",name];
        [self setValue:nil forKey:propertyName];
    }
    free(propertyList);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WGB_DATA_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 赋值方法,可根据实际情况自行修改

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    [super setValue:value forKey:key];
}


@end
