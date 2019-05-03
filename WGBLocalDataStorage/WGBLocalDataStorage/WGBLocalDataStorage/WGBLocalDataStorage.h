//
//  WGBLocalDataStorage.h
//  WGBLocalDataStorage
//
//  Created by 王贵彬 on 2019/5/3.
//  Copyright © 2019 王贵彬. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;

@interface WGBCodingObject : NSObject<NSCoding>

// WGBCodingObject 是利用runtime创建的归档对象,可自定义添加属性
// 属性必须遵循NSCoding协议
/**
 不需要归档的属性名称集合
 */
@property(nonatomic,copy)NSArray <NSString *>*ignoreEncodePropertyList;
/**
 是否需要管理提示Log打印,默认为NO 这个可有可无不用管
 */
@property(nonatomic,assign)BOOL closeAlertLog;

@end


@interface WGBLocalDataStorage : WGBCodingObject

// WGBLocalDataStorage  单例对象.
+ (instancetype)defaultDataStorage;

/**
 存储或更新本地数据偏好设置
 */
- (void)saveOrUpdateDataStorageResult;

/**
 删除本地数据
 */
- (void)deleteDataStorage;

// 请在下方添加你所需要保存的属性,注意要遵循NSCoding协议,或者继承于WGBCodingObject类...  暂不支持int,float,BOOL等类型

//自定义缓存的属性 例如...以下
/**
 1.  实例化单例 -> 持有属性的修改 -> 调用保存更新接口
 2.  删除持有实例 -> 是删除所有这个类持有的对象
 3. 建议: 自定义`WGBCodingObject`子类, 修改粒度更小(细化), 比如只想删除部分数据的话 只需要将持有的子类对象置空即可, 没必要删除整个库,除非删库跑路🏃
  */
@property(nonatomic,copy)NSString *phone;
@property(nonatomic,copy)NSString *password;
@property (nonatomic,strong) UserModel *userInfo; //该类继承于WGBCodingObject类


@end

