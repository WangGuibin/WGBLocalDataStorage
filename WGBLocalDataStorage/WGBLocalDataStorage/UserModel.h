//
//  UserModel.h
//  WGBLocalDataStorage
//
//  Created by 王贵彬 on 2019/5/3.
//  Copyright © 2019 王贵彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGBLocalDataStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : WGBCodingObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *age;
@property (nonatomic,copy) NSString *sex;

//隐私 不需要归档
@property (nonatomic,strong) NSNumber *income;
@property (nonatomic,strong) NSNumber *haveBoyFriend;

@end

NS_ASSUME_NONNULL_END
