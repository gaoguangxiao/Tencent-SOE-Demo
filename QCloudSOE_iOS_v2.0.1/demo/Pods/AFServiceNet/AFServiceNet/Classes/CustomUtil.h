//
//  CustomUtil.h
//  SimpleSrore
//
//  Created by ggx on 2017/3/15.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomUtil : NSObject
//登录状态
+(BOOL)isUserLogin;
+(void)saveLoginStatus:(NSString *)loginStatus;
+(void)deloginStatus;

+(void)saveAcessToken:(NSString *)token;
+(void)delAcessToken;
+(NSString *)getToken;

//保存第一次安装App
+(void)saveFirstLaunch:(BOOL)isLaunch;
+(BOOL)isFirstLaunch;

//引导页
+(void)saveFirstShow:(NSString *)str;
+(NSString *)getFirstShow;

@end
