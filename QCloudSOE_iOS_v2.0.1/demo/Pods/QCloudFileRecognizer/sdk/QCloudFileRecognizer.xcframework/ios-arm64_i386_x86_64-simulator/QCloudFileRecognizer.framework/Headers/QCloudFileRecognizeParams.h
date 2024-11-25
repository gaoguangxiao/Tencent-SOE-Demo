//
//  QCloudFileParams.h
//  QCloudSDK
//
//  Created by Sword on 2019/8/8.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <QCloudFileRecognizer/QCloudFileRecognizerCommonParams.h>


typedef NS_ENUM(NSInteger, QCloudAudioSourceType) {
    QCloudAudioSourceTypeNone = -1,          //未知
    QCloudAudioSourceTypeUrl = 0,            //语音url
    QCloudAudioSourceTypeAudioData,          //语音数据
};


@interface QCloudFileRecognizeParams : QCloudFileRecognizerCommonParams 

@property (nonatomic, assign) NSInteger channelNum;
@property (nonatomic, copy) NSString*  engineModelType;
/*
 * 可选,识别结果回调URL，用户自行搭建的用于接收识别结果的服务器地址， 长度小于2048字节
 */
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, strong) NSString *requestId;
/*
 * 语音数据来源 QCloudAudioSourceTypeUrl:语音URL, QCloudAudioSourceTypeAudioData:语音数据（post body）。
 */
@property (nonatomic, assign) QCloudAudioSourceType sourceType;
/*
 * sourceType=QCloudAudioSourceTypeUrl时，必填
 */
@property (nonatomic, strong) NSString *audioUrl;
/*
 * sourceType=QCloudAudioSourceTypeAudioData时，必填
 */
@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, assign) NSInteger resTextFormat;
//@property (nonatomic, assign, readonly) NSInteger subServiceType;      //子服务类型。0：录音文件识别

@property (nonatomic, assign) NSInteger filterDirty;                   //过滤脏词(目前支持中文普通话引擎).
@property (nonatomic, assign) NSInteger filterModal;                   //过滤语气词(目前支持中文普通话引擎).
@property (nonatomic, assign) NSInteger convertNumMode;                //是否进行阿拉伯数字智能转换.
@property (nonatomic, strong) NSString *hotwordId;                     //热词id.

@property (nonatomic, assign) NSInteger speakerDiarization;            //是否开启话者分离，0：不开启，1：开启(仅支持8k_zh/16k_zh引擎模型，单声道音频)
@property (nonatomic, assign) NSInteger speakerNumber;                 //话者分离人数（需配合开启话者分离使用），支持2-10（8k_zh仅支持2， 16k_zh支持2-10）

@end
