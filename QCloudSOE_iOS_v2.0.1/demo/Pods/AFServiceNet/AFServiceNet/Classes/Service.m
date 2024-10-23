//
//  Service.m
//  CPetro
//
//  Created by ggx on 2017/3/10.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import "Service.h"
#import <YYModel/YYModel.h>
#import "BaseNetMacro.h"
#import "CustomUtil.h"

static AFHTTPSessionManager *manager;

@implementation Service
//
+ (AFHTTPSessionManager *)shareSessionManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        if (cerSet.count == 0){
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
            securityPolicy.allowInvalidCertificates = YES;
            securityPolicy.validatesDomainName = NO;
            manager.securityPolicy = securityPolicy;
        }else{
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
            securityPolicy.allowInvalidCertificates = YES;
            manager.securityPolicy = securityPolicy;
        }
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"application/x-www-form-urlencoded",@"form-data", nil];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy.validatesDomainName = NO;
        manager.requestSerializer.timeoutInterval = 10;
        
    });
    return manager;
}



+(CGDataResult *)loadNetWorkingByParameters:(id)parameters
                            andBymethodName:(NSString *)methodName {
    return [self loadNetWorkingMethodisPost:YES
                               ByParameters:parameters
                            andBymethodName:methodName];
}

+(CGDataResult *)loadNetWorkingMethodisPost:(BOOL)isPost
                               ByParameters:(id)parameters
                            andBymethodName:(NSString *)methodName {
    return [self loadNetWorkingByParameters:parameters
                            andBymethodName:methodName
                                  andMethod:isPost
                                  isFullUrl:NO];
}

+(CGDataResult *)loadNetWorkingByParameters:(id)parameters
                            andBymethodName:(NSString *)methodName
                                  andMethod:(BOOL)isPost
                                  isFullUrl:(BOOL)isFull {
    return [CGDataResult getResultFromData:[Service backDataResults_webService:methodName
                                                                        AndDic:parameters
                                                                     andMethod:isPost
                                                                     isFullUrl:isFull]];
}

+(NSDictionary *)backDataResults_webService:(NSString *)webService
                                     AndDic:(id)dicTionary
                                  andMethod:(BOOL)isPost
                                  isFullUrl:(BOOL)isFull{

    NSString *urlNew = [NSString stringWithFormat:@"%@%@",WEBSEARVICE,webService];
    if (isFull) {
        urlNew = webService;
    }

    __block NSDictionary *dic = [NSDictionary new];
    //1、创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *token = CustomUtil.getToken;
    if (token) {
        [self.shareSessionManger.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    if (isPost) {
        [self.shareSessionManger POST:urlNew parameters:dicTionary headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            /* 将得到的 JSON 数据转换成 NSDictionary 字典 */
            dic = responseObject;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dic = @{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"};
            NSLog(@"error:%@",error);
            dispatch_semaphore_signal(semaphore);
        }];
        
    } else {
        [self.shareSessionManger GET:urlNew parameters:dicTionary headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            dic = responseObject;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dic = @{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"};
            NSLog(@"error:%@",error);
            dispatch_semaphore_signal(semaphore);
        }];
        
    }
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);//等待
    NSLog(@"URL：%@\n请求参数：%@\n响应结果：%@",urlNew,dicTionary,dic.yy_modelToJSONObject);
    return dic?dic:@{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"};
    
}

+(CGDataResult *)postDataBywebService:(NSString *)webService andBodyData:(NSData *)data parameters:(NSDictionary *)parameters {
    
    NSString *urlNew = [NSString stringWithFormat:@"%@%@",WEBSEARVICE,webService];
    //
    NSString *token = CustomUtil.getToken;
    if (token) {
        [self.shareSessionManger.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    __block NSDictionary *dic = [NSDictionary new];
    //1、创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.shareSessionManger POST:urlNew parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithHeaders:nil body:data];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"%.2lf%%", progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dic = responseObject;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dic = @{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"};
        NSLog(@"error:%@",error);
        dispatch_semaphore_signal(semaphore);
        
    }];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);//等待
    NSLog(@"响应结果：%@",dic.yy_modelToJSONString);
    return [CGDataResult getResultFromData:dic?dic:@{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"}];
}

+(CGDataResult *)postImageBywebService:(NSString *)webService andFilePath:(NSURL *)filePath parameters:(NSDictionary *)parameters {
    NSString *urlNew = [NSString stringWithFormat:@"%@%@",WEBSEARVICE,webService];
    //
    NSString *token = CustomUtil.getToken;
    if (token) {
        [self.shareSessionManger.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    
    __block NSDictionary *dic = [NSDictionary new];
    //1、创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.shareSessionManger POST:urlNew parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:filePath name:@"files" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"%.2lf%%", progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dic = responseObject;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dic = @{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"};
        NSLog(@"error:%@",error);
        dispatch_semaphore_signal(semaphore);
        
    }];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);//等待
    NSLog(@"响应结果：%@",dic.yy_modelToJSONString);
    return [CGDataResult getResultFromData:dic?dic:@{@"msg":@"亲，网速过慢，请检查一下网络哦～",@"data":@"",@"code":@"400"}];
}

/**调试输出网址*/
+(void)deletebugDic:(NSMutableDictionary *)dicTionary andBugUrl:(NSString *)url{
    //调试
    NSMutableString *mutableString = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@",url]];
    for (NSString *key in dicTionary.allKeys) {
        id value = dicTionary[key];
        if (value != nil) {
            NSString *insertValue = @"";
            if ([value isKindOfClass:NSString.class]) {
                insertValue = dicTionary[key];
//                [dicTionary removeObjectForKey:key];
            } else if ([value isKindOfClass:NSNumber.class]) {
                insertValue = [NSString stringWithFormat:@"%@",value];
            }
            [mutableString appendFormat:@"%@", [NSString stringWithFormat:@"&%@=%@",key,insertValue]];
            
        }
    }
    NSLog(@"%@",mutableString);
}

//处理回车单引号引起的错误
+(NSDictionary *)getDicFromData:(NSData *)d1{
    //处理掉回车、单引号引起的格式出错
    NSString *str = [[NSString alloc]initWithData:d1 encoding:NSUTF8StringEncoding];
    NSString *str1 = [[[str stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"]stringByReplacingOccurrencesOfString:@"\r" withString:@"%0D"] stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];
    NSData *d = [str1 dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSDictionary *dic = [[NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    
    dic = [self dealObjectWithObj:dic];
    if (dic == nil) {
        NSLog(@"%@",str1);
    }
    return dic;
}
/**
 *  递归调用
 *
 *  @param obj 要处理的对象
 *
 *  @return 处理过后的值
 */
+(id)dealObjectWithObj:(id)obj{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray new];
        for (id d in (NSArray *)obj) {
            [arr addObject:[self dealObjectWithObj:d]];
        }
        return arr;
    }else if ([obj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *dic = [NSMutableDictionary new];
        for (NSString *s in ((NSDictionary *)obj).allKeys) {
            dic[s] = [self dealObjectWithObj:obj[s]];
        }
        return dic;
    }else{
        NSString *str = obj;
        if ([str isKindOfClass:[NSString class]]) {
            str = [[[str stringByReplacingOccurrencesOfString:@"%0A" withString:@"\n"]stringByReplacingOccurrencesOfString:@"%0D" withString:@"\r"] stringByReplacingOccurrencesOfString:@"%09" withString:@"\t"] ;
        }
        return str;
    }
}
+(NSString *)getURLByString:(NSString *)str{
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}
@end

