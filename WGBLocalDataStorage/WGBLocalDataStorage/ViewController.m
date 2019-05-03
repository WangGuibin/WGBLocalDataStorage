//
//  ViewController.m
//  WGBLocalDataStorage
//
//  Created by 王贵彬 on 2019/5/3.
//  Copyright © 2019 王贵彬. All rights reserved.
//

#import "ViewController.h"
#import "WGBLocalDataStorage.h"
#import "UserModel.h"

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UITextView *logScreenTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


//增
- (IBAction)saveDataAction:(id)sender {
    [WGBLocalDataStorage defaultDataStorage].phone = @"13058088469";
    [WGBLocalDataStorage defaultDataStorage].password = @"123456";
    UserModel *user = [UserModel new];
    user.name = @"灭霸";
    user.age = @(18);
    user.sex = @"男";

    user.income = @(66666666);
    user.haveBoyFriend = @(1);
    [WGBLocalDataStorage defaultDataStorage].userInfo = user;
//   [WGBLocalDataStorage defaultDataStorage].userInfo.ignoreEncodePropertyList = @[@"income",@"haveBoyFriend"];
    [[WGBLocalDataStorage defaultDataStorage] saveOrUpdateDataStorageResult];
    [self display];
}

//改
- (IBAction)updateDataAction:(id)sender {
    UserModel *user =  [WGBLocalDataStorage defaultDataStorage].userInfo;
    user.name = @"钢铁侠";
    user.age = @(66);
    user.sex = @"unknow";
    [WGBLocalDataStorage defaultDataStorage].password = @"******";
    [[WGBLocalDataStorage defaultDataStorage] saveOrUpdateDataStorageResult];
    [self display];
}

//删
- (IBAction)deleteDataAction:(id)sender {
    [[WGBLocalDataStorage defaultDataStorage] deleteDataStorage];
    [self display];

}


//查
- (IBAction)displayDataAction:(id)sender {
    [self display];
}

- (void)display{
    self.logScreenTextView.text = nil;
    WGBLocalDataStorage *localDataStorage = [WGBLocalDataStorage defaultDataStorage];
    
    NSMutableString *strM = [NSMutableString string];
    NSString *phone = localDataStorage.phone;
    [strM appendFormat:@"phone: %@\n",phone];
    
    NSString *pwd = localDataStorage.password;
    [strM appendFormat:@"password: %@\n",pwd];
    
    NSString *name = localDataStorage.userInfo.name;
    [strM appendFormat:@"name: %@\n",name];

    NSString *sex = localDataStorage.userInfo.sex;
    [strM appendFormat:@"sex: %@\n",sex];

    NSNumber *age = localDataStorage.userInfo.age;
    [strM appendFormat:@"age: %@\n",age];

    NSNumber *income = localDataStorage.userInfo.income;
    [strM appendFormat:@"income: %@\n",income];

    NSNumber *haveFriend = localDataStorage.userInfo.haveBoyFriend;
    [strM appendFormat:@"haveBoyFriend: %@\n",haveFriend];

    [self.logScreenTextView insertText: strM];
    [self.logScreenTextView scrollsToTop];
}

@end
