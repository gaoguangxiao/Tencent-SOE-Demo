//
//  QCloudFlashFileParams.h
//  QCloudSDK
//
//  Created by dgw
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <QCloudFileRecognizer/QCloudFileRecognizerCommonParams.h>

@interface QCloudFlashFileRecognizeParams : QCloudFileRecognizerCommonParams

//音频数据必填
@property (nonatomic, strong) NSData *audioData;

//音频格式。支持 wav、pcm、ogg-opus、speex、silk、mp3、m4a、aac。
@property (nonatomic, strong) NSString *voiceFormat;

//引擎模型类型,默认16k_zh。8k_zh：8k 中文普通话通用；16k_zh：16k 中文普通话通用；16k_zh_video：16k音视频领域。
@property (nonatomic, copy) NSString* engineModelType;

// 0 ：默认状态 不过滤脏话 1：过滤脏话
@property (nonatomic, assign) NSInteger filterDirty;

// 0 ：默认状态 不过滤语气词  1：过滤部分语气词 2:严格过滤
@property (nonatomic, assign) NSInteger filterModal;

// 0 ：默认状态 不过滤句末的句号 1：滤句末的句号
@property (nonatomic, assign) NSInteger  filterPunc;

//1：默认状态 根据场景智能转换为阿拉伯数字；0：全部转为中文数字。
@property (nonatomic, assign) NSInteger convertNumMode;

//是否开启说话人分离（目前支持中文普通话引擎），默认为0，0：不开启，1：开启。
@property (nonatomic, assign) NSInteger speakerDiarization;

//是否只识别首个声道，默认为1。0：识别所有声道；1：识别首个声道。
@property (nonatomic, assign) NSInteger firstChannelOnly;

//是否显示词级别时间戳，默认为0。0：不显示；1：显示，不包含标点时间戳，2：显示，包含标点时间戳。
@property (nonatomic, assign) NSInteger wordInfo;

//网络超时时间，默认600s,您可以根据业务需求更改此值；注意：如果设置过短的时间，网络超时断开将无法获取到识别结果，并且会消耗该音频时长的识别额度
@property (nonatomic, assign) NSInteger requestTimeoutInternval;


@property (nonatomic, assign) NSInteger reinforceHotword __attribute__((deprecated("该属性即将过期，可通过在控制台配置热词列表里的热词权重为100，并将热词列表ID通过hotwordID属性传入SDK，实现增强热词的功能"))); // 热词增强功能。默认为0，0：不开启，1：开启。开启后（仅支持8k_zh，16k_zh），将开启同音替换功能，同音字、词在热词中配置。

@property (nonatomic, assign) NSInteger sentenceMaxLength; // 单标点最多字数，取值范围：[6，40]。默认为0，不开启该功能。该参数可用于字幕生成场景，控制单行字幕最大字数。

@property (nonatomic, copy) NSString* customizationID; // 自学习模型 id。如设置了该参数，将生效对应的自学习模型。

@property (nonatomic, copy) NSString* hotwordID; // 热词表 id。如不设置该参数，自动生效默认热词表；如设置了该参数，那么将生效对应的热词表。

@end
