//
//  QCloudBaseRecognizer.h  为历史用户保留的旧版异步文件识别接口，不建议调用，不再维护，不提供demo
//
//  Created by Sword on 2019/8/8.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <QCloudFileRecognizer/QCloudFileRecognizerConfig.h>

NS_ASSUME_NONNULL_BEGIN
@protocol QCloudFileRecognizerDelegate;

@class QCloudFileRecognizeParams;

@interface QCloudFileRecognizer : NSObject

@property (nonatomic, strong, readonly) QCloudFileRecognizerConfig  *config;


@property (nonatomic, weak) id<QCloudFileRecognizerDelegate> _Nullable delegate __attribute__ ((deprecated));



- (instancetype)initWithConfig:(QCloudFileRecognizerConfig *)config  __attribute__ ((deprecated));
/**
 * 通过appId secretId secretKey初始化
 * @param appid     腾讯云appId        基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey    基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid secretId:(NSString *)secretId secretKey:(NSString *)secretKey __attribute__ ((deprecated));

/**
 * 通过appId secretId secretKey初始化, 临时鉴权
 * @param appid     腾讯云appId        基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey    基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid secretId:(NSString *)secretId secretKey:(NSString *)secretKey token:(NSString *)token __attribute__ ((deprecated));



/**
 文件识别接口

 @param params 识别参数
 @return 返回请求唯一标识requestId，回调中用到
 */
- (NSInteger)recognize:(QCloudFileRecognizeParams *_Nonnull)params;

/**
 获取识别结果，走回调。该方法会轮询结果。使用场景：clear调用了之后，想获取之前的识别结果，或者识别文件太大，app关掉了，下次打开想获取上次的识别结果

 @taskId taskId 录音唯一标识
 @requestId 返回的请求唯一标识requestId
 */

- (void)pollingRecognizeResult:(NSString *_Nonnull)taskId clientRequestId:(NSString *_Nonnull)requestId;

/**
 获取所有taskId 和 requestId，只能在clear 方法调用前获取。fileRecognizerDidStart调用前为空。

 @NSArray： @[@{@"requestId":@"taskId"},...]
 */

- (NSArray *_Nullable)getAllTaskIdAndRequesId;

- (void)clear;


-(void)EnableDebugLog:(BOOL)enable;

@end


@protocol QCloudFileRecognizerDelegate <NSObject>
@optional

/**
 录音文件识别成功回调

 @param recognizer 录音文件识别器
 @param requestId 请求唯一标识requestId,recognize:接口返回
 @param text 识别文本
 @param resultData 原始数据
 */
- (void)fileRecognizer:(QCloudFileRecognizer *_Nullable)recognizer requestId:(NSInteger)requestId text:(nullable NSString *)text resultData:(nullable NSDictionary *)resultData;
/**
 录音文件识别失败回调
 
 @param recognizer 录音文件识别器
 @param requestId 请求唯一标识requestId,recognize:接口返回
 @param error 识别错误，出现错误此字段有
 @param resultData 原始数据
 */
- (void)fileRecognizer:(QCloudFileRecognizer *_Nullable)recognizer requestId:(NSInteger)requestId error:(nullable NSError *)error resultData:(nullable NSDictionary *)resultData;


/**
 录音文件已上传服务器，正在排队识别中
 
 @param recognizer 录音文件识别器
 @param requestId 请求唯一标识requestId,recognize:接口返回
 @param taskId 向服务器查询识别结果唯一标识
 */
- (void)fileRecognizerDidStart:(QCloudFileRecognizer *_Nullable)recognizer requestId:(NSString *_Nonnull)requestId taskId:(NSString *_Nonnull)taskId;
/**
 * 日志输出
 * @param log 日志
 */
- (void)FileRecgnizerLogOutPutWithLog:(NSString *_Nullable)log;



@end

NS_ASSUME_NONNULL_END

