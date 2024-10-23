//
//  TESTDATA.m
//  KnowXiTong
//
//  Created by ggx on 2017/6/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import "TESTDATA.h"

#import "CGDataResult.h"
@implementation TESTDATA
+(CGDataResult *)testData:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    [NSData da]
    //    //将JSON数据转NSArray或NSDictionary
    NSDictionary *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (!dictArray) {
        return nil;
    }
    NSString *jstrParam = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictArray options:0 error:nil] encoding:NSUTF8StringEncoding];
//    URLLog(@"%@",jstrParam);
    return [CGDataResult getResultFromData:dictArray];
}

+ (NSString *)loadTestjson:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    [NSData da]
    //    //将JSON数据转NSArray或NSDictionary
    NSDictionary *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (!dictArray) {
        return nil;
    }
    NSString *jstrParam = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictArray options:0 error:nil] encoding:NSUTF8StringEncoding];
//    URLLog(@"%@",jstrParam);
    return jstrParam;
}

+ (NSString *)loadTestTxt:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
//    [NSData da]
    //    //将JSON数据转NSArray或NSDictionary
//    NSDictionary *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    if (!dictArray) {
//        return nil;
//    }
    NSString *jstrParam = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    URLLog(@"%@",jstrParam);
    return jstrParam;
}
@end
