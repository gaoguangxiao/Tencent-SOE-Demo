//
//  CGDataResult.h
//  CPetro
//
//  Created by ggx on 2017/3/10.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface CGDataExtensionResult : NSObject

@property (nonatomic, copy)   NSArray *list;
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger total;
@end

@interface CGDataResult : NSObject
@property(strong,nonatomic)NSString *errorMsg;
@property(assign,nonatomic)BOOL status;
@property(strong,nonatomic)id dataList;
@property(nonatomic, assign) NSInteger code;

@property(nonatomic, strong) CGDataExtensionResult *extensionResult;

+(CGDataResult *)getResultFromData:(NSDictionary *)dic;

//+(CGDataResult *)getResultFromDic:(NSDictionary *)dic;
@end
