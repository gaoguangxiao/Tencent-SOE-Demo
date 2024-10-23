
//
//  CGDataResult.m
//  CPetro
//
//  Created by ggx on 2017/3/10.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import "CGDataResult.h"
#import <objc/runtime.h>
#import "BaseNetMacro.h"

@implementation CGDataExtensionResult

@end

@implementation CGDataResult
+(CGDataResult *)getResultFromData:(id )data{
    CGDataResult *r;
    if ([data isKindOfClass:[NSDictionary class]]) {
       r= [self getResultFromDic:data];
    }else if ([data isKindOfClass:[NSArray class]]){
      r=  [self getResultsFromArray:data];
    }
    return r;
}
+(CGDataResult *)getResultFromDic:(NSDictionary *)dic{
    CGDataResult *result = [[CGDataResult alloc]init];
    if (dic) {//成功
        result.errorMsg = [dic objectForKey:API_MSG];
        result.code   = [[dic objectForKey:API_CODE] integerValue];
        result.status = [[dic objectForKey:API_SUCCESS] boolValue];
        id datalist = [dic objectForKey:API_DATA];
        if (datalist) {
            result.dataList = datalist;
        }else{
            result.dataList = [dic objectForKey:API_DATA];
        }
        //如果datalist是字典类型，需要进一步解析
        if ([result.dataList isKindOfClass:NSDictionary.class]) {
            NSDictionary *dataDict = (NSDictionary *)result.dataList;
            result.extensionResult = [CGDataExtensionResult new];
            result.extensionResult.pages = [[dataDict valueForKey:API_DATAPAGES] integerValue];
            result.extensionResult.list = [dataDict valueForKey:API_DATALIST];
            result.extensionResult.total = [[dataDict valueForKey:API_DATATOTAL] integerValue];
        }
    } else{
        result.errorMsg = @"获取失败";
        result.status = @(NO);
        id datalist = [dic objectForKey:API_DATA];
        if (datalist) {
            result.dataList = datalist;
        }
    }
    return result;
}
#pragma mark -处理数组数据
+(CGDataResult *)getResultsFromArray:(NSArray *)array{
    CGDataResult *result = [[CGDataResult alloc]init];
    if (array&&array.count>0) {
        result.errorMsg = @"获取成功";
        result.status = @(YES);
        id datalist = array;
        if (datalist) {
            result.dataList = datalist;
        }else{
            result.dataList = @[];
        }
    }else{
        result.errorMsg = @"数组为空";
        result.status = @(NO);
        id datalist = array;
        if (datalist) {
            result.dataList = datalist;
        }else{
            result.dataList = @[];
        }
    }
    return result;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@",[self toDictionary]];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    
    //  取得当前类类型
    Class cls = [self class];
    
    unsigned int ivarsCnt = 0;
    //　获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如 @property(retain) NSString *abc;则 key == _abc;
        
        //　获取变量值
        id value = [self valueForKey:key];
        
        //　取得变量类型
        // 通过 type[0]可以判断其具体的内置类型
        //        const char *type = ivar_getTypeEncoding(ivar);
        
        if (value)
        {
            [dictionaryFormat setObject:value forKey:key];
        }
    }
    return dictionaryFormat;
}

@end
