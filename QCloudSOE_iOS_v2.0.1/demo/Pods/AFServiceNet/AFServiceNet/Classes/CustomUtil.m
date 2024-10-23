//
//  CustomUtil.m
//  SimpleSrore
//
//  Created by ggx on 2017/3/15.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import "CustomUtil.h"
#import <YYModel/YYModel.h>

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

#define U_LOGIN @"LOGIN"
#define VERSION @"VERSION"//第一次引导页
#define U_LAUNCHINFO @"LAUNCHINFO"//第一次启动安装
#define U_TOKEN @"TOKEN"//用户信息
#define U_INFO @"U_INFO"

@implementation CustomUtil

+(BOOL)isUserLogin{
    NSUserDefaults  *settings = USER_DEFAULT;
    NSString *loginSta = [settings valueForKey:U_LOGIN]?[settings valueForKey:U_LOGIN]:@"";;
    if (loginSta && loginSta.length) {
        return YES;
    }else{
        return NO;
    }
}

+(void)saveLoginStatus:(NSString *)loginStatus {
    NSUserDefaults  *settings = USER_DEFAULT;
    [settings setObject:loginStatus forKey:U_LOGIN];
    [settings synchronize];
}

+(void)deloginStatus {
    NSUserDefaults  *settings = USER_DEFAULT;
    //删除登录状态
    [settings removeObjectForKey:U_LOGIN];
    //删除token信息
    [settings removeObjectForKey:U_TOKEN];
    //手势登录信息
    
    [settings synchronize];
}

//token信息
+(void)saveAcessToken:(NSString *)token{
    NSUserDefaults  *settings = USER_DEFAULT;
    [settings setObject:token forKey:U_TOKEN];
    [settings synchronize];
}

+(NSString *)getToken{
    NSUserDefaults  *settings = USER_DEFAULT;
    return [settings valueForKey:U_TOKEN]?[settings valueForKey:U_TOKEN]:@"";
}

+(void)delAcessToken{
    NSUserDefaults  *settings = USER_DEFAULT;
    [settings removeObjectForKey:U_TOKEN];
    [settings synchronize];
}

#pragma mark - 第一次启动
+(void)saveFirstLaunch:(BOOL)isLaunch {
    [USER_DEFAULT setObject:@(isLaunch) forKey:U_LAUNCHINFO];
    [USER_DEFAULT synchronize];
}

+(BOOL)isFirstLaunch {
    id isResult = [USER_DEFAULT valueForKey:U_LAUNCHINFO];
    if (isResult == nil) {
        return YES;
    }
    return NO;
}

+(void)saveFirstShow:(NSString *)str {
    [USER_DEFAULT setObject:str forKey:VERSION];
    [USER_DEFAULT synchronize];
}
+(NSString *)getFirstShow {
    return [USER_DEFAULT valueForKey:VERSION];
}
@end
