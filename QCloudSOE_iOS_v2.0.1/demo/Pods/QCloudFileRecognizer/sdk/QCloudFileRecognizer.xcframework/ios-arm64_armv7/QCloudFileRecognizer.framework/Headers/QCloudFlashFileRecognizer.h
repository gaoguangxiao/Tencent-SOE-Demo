//
//  QCloudBaseRecognizer.h
//  QCloudSDK
//
//  Created by dgw.
//  Copyright © 2019 Tencent. All rights reserved.
//


#import <QCloudFileRecognizer/QCloudFileRecognizerConfig.h>

NS_ASSUME_NONNULL_BEGIN
@protocol QCloudFlashFileRecognizerDelegate;

@class QCloudFlashFileRecognizeParams;

@interface QCloudFlashFileRecognizer : NSObject

@property (nonatomic, strong, readonly) QCloudFileRecognizerConfig  *config;

@property (nonatomic, weak) id<QCloudFlashFileRecognizerDelegate> _Nullable delegate;


- (instancetype)initWithConfig:(QCloudFileRecognizerConfig *)config;
/**
 * 通过appId secretId secretKey初始化
 * @param appid     腾讯云appId        基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey    基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid secretId:(NSString *)secretId secretKey:(NSString *)secretKey;

/**
 * 通过appId secretId secretKey初始化, 临时鉴权
 * @param appid     腾讯云appId        基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey    基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid secretId:(NSString *)secretId secretKey:(NSString *)secretKey token:(NSString *)token;


/**
 文件识别接口

 @param params 识别参数
 */
- (void)recognize:(QCloudFlashFileRecognizeParams *_Nonnull)params;

-(void)EnableDebugLog:(BOOL)enable;

@end


@protocol QCloudFlashFileRecognizerDelegate <NSObject>
@optional

/**
 录音文件识别成功回调

 @param recognizer 录音文件识别器
 @param status 非0时识别失败
 @param text 识别文本
 @param resultData 原始数据
 */
- (void)FlashFileRecognizer:(QCloudFlashFileRecognizer *_Nullable)recognizer status:(nullable NSInteger *) status text:(nullable NSString *)text resultData:(nullable NSDictionary *)resultData;
/**
 录音文件识别失败回调
 
 @param recognizer 录音文件识别器
 @param error 识别错误，出现错误此字段有
 @param resultData 原始数据
 */
- (void)FlashFileRecognizer:(QCloudFlashFileRecognizer *_Nullable)recognizer error:(nullable NSError *)error resultData:(nullable NSDictionary *)resultData;

/**
 * 日志输出
 * @param log 日志
 */
- (void)FlashFileRecgnizerLogOutPutWithLog:(NSString *_Nullable)log;


@end
NS_ASSUME_NONNULL_END
