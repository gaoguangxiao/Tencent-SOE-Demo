//
//  QCloudConfig.h  为历史用户保留的旧版异步文件识别接口，不建议调用，不再维护，不提供demo
//  QCloudSDK
//
//  Created by Sword on 2019/3/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface QCloudFileRecognizerConfig : NSObject

//通用配置参数
@property (nonatomic, strong, readonly) NSString *appId;        //腾讯云appId     基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, strong, readonly) NSString *secretId;     //腾讯云secretId  基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, strong, readonly) NSString *secretKey;    //腾讯云secretKey 基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, assign, readonly) NSInteger projectId;    //腾讯云projectId 基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, strong, readonly) NSString *token;    //腾讯云临时鉴权token
//实时语音识别相关参数

@property (nonatomic, assign) NSInteger requestTimeout;                       //网络请求超时时间，单位:秒, 取值范围[5-60], 默认20
@property (nonatomic, assign) NSInteger filterDirty;                          //是否过滤脏词（目前支持中文普通话引擎） 具体的取值见https://cloud.tencent.com/document/product/1093/35799  的filter_dirty参数
@property (nonatomic, assign) NSInteger filterModal;                          //过滤语气词(目前支持中文普通话引擎). 具体的取值见https://cloud.tencent.com/document/product/1093/35799  的filter_modal参数
@property (nonatomic, assign) NSInteger filterPunc;                           //过滤句末的句号(目前支持中文普通话引擎). 具体的取值见https://cloud.tencent.com/document/product/1093/35799  的filter_punc参数
@property (nonatomic, assign) NSInteger convertNumMode;                       //是否进行阿拉伯数字智能转换。 具体的取值见https://cloud.tencent.com/document/product/1093/35799  的convert_num_mode参数
@property (nonatomic, strong) NSString *hotwordId;                            //热词id。 具体的取值见https://cloud.tencent.com/document/product/1093/35799  的hotword_id参数

@property (nonatomic, assign) NSInteger wordInfo;
//是否显示词级别时间戳。0：不显示；1：显示，不包含标点时间戳，2：显示，包含标点时间戳。默认为0。


/**
 * 初始化方法
 * @param appid     腾讯云appId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId  基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey 基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param projectId 腾讯云projectId 基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid
                     secretId:(NSString *)secretId
                    secretKey:(NSString *)secretKey
                    projectId:(NSInteger)projectId;


- (instancetype)initWithAppId:(NSString *)appid
                     secretId:(NSString *)secretId
                    secretKey:(NSString *)secretKey
                    token:(NSString *)token
                    projectId:(NSInteger)projectId;

@end

NS_ASSUME_NONNULL_END
