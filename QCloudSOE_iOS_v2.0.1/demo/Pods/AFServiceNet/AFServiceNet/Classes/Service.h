//
//  Service.h
//  CPetro
//
//  Created by ggx on 2017/3/10.
//  Copyright © 2017年 高广校. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CGDataResult.h"

typedef void (^returnObject)(CGDataResult *obj);

@interface Service : NSObject

+(AFHTTPSessionManager *)shareSessionManger;

@property(nonatomic,strong) AFHTTPSessionManager * manager;
/**
 *  获取网络数据
 *
 *  @param parameters @{}
 *  @param methodName 接口名字
 *
 *  @return return value description
 */
+(CGDataResult *)loadNetWorkingByParameters:(id)parameters andBymethodName:(NSString *)methodName;

/// 获取网络数据
/// @param isPost <#isPost description#>
/// @param parameters <#parameters description#>
/// @param methodName <#methodName description#>
+(CGDataResult *)loadNetWorkingMethodisPost:(BOOL)isPost ByParameters:(NSDictionary *)parameters andBymethodName:(NSString *)methodName;

/// 获取网络数据
/// @param parameters <#parameters description#>
/// @param methodName <#methodName description#>
/// @param isPost <#isPost description#>
/// @param isFull <#isFull description#>
+(CGDataResult *)loadNetWorkingByParameters:(id)parameters
                            andBymethodName:(NSString *)methodName
                                  andMethod:(BOOL)isPost
                                  isFullUrl:(BOOL)isFull;

+(CGDataResult *)postImageBywebService:(NSString *)webService andFilePath:(NSURL *)filePath parameters:(NSDictionary *)parameters;

+(CGDataResult *)postDataBywebService:(NSString *)webService andBodyData:(NSData *)data parameters:(NSDictionary *)parameters;
//+(void)postImageByUrl:(NSString*)url withParameters:(NSDictionary*)parameters andImageData:(NSData*)imageData imageKey:(NSString *)imageKey andComplain:(returnObject)complain;

@end
