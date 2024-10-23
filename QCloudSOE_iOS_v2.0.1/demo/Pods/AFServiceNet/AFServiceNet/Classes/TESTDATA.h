//
//  TESTDATA.h
//  KnowXiTong
//
//  Created by ggx on 2017/6/9.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGDataResult.h"
@interface TESTDATA : NSObject
+(CGDataResult *)testData:(NSString *)name;


/// 返回JSON
/// - Parameter name: <#name description#>
+ (NSString *)loadTestjson:(NSString *)name;

/// 读取txt文档
+ (NSString *)loadTestTxt:(NSString *)name;
@end
