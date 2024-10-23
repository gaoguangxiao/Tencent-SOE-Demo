//
//  RSBridgeAudioModel.swift
//  RSBridgeAudioEvaluation
//
//  Created by 高广校 on 2024/2/6.
//

import Foundation
import SmartCodable
import ZKBaseSwiftProject

public class RSBridgeAudioModel: SmartCodable {
    
    public var TIMConfig: TIMConfigModel?
    
    public var speechData: BridgeAnswerDetail?
    
    /// 最长录音时长 单位s，最短5s
    public var duration: Double = 5
    
    public var path: String?
    
    public var score : Bool = true //是否需要打分，0：不需要、1：需要
    
    /// 打分方式 0: 服务端打分， 1: 客户端打分 默认值：1
    public var scoreType = 1 //分数类型
//    public var upload = 0
    
    /// 是否开启流式判卷 默认为true
    public var stream = true
    
    /// 静音时长 默认6000ms
    public var vadInterval = 6000
    
    /// 是否支持静音检测，默认为true
    public var vad = true
    
//    public var speechData : Dictionary<String,Any> = [:]
    
    /// 句子中单词或音素长度
    public var wordsCount: Int?
    
    public var lastWord: String?
    
    /// 是否检测录音音量的变化，默认true
    public var enableDetectVolume = true
    
    /// 录音音量回调时间，毫秒，默认200ms
    public var minVolumeCallbackTime = 200
    
    ///同时启动语音识别
    public var recognition = true
    
    ///是否开启语音识别流式
    public var recognitionStream = false
    
    /// 语言识别过滤敏感词
    public var filterSensitive = false
    required public init() {

    }
}

public extension RSBridgeAudioModel {
    
    var fillRecordPath: String {
        return ZKDiskTool.shared.createAudioRecordpath(path: path ?? "", fileExt: "wav")
    }
}

//https://cloud.tencent.com/document/product/884/84102
public class TIMConfigModel: SmartCodable {

    ///  // 0单词，1句子，2段落，3自由说，4单词纠错，5情景，6多分支，7单词实时，8拼音
    public var evalMode: Int?
    
    /// 苛刻度 0 - 1 取值为[1.0 - 4.0]范围内的浮点数
    public var scoreCoeff: Float = 1.0
    
    /// 评测文本
    public var refText: String?
 
    /// 输入文本模式。0:普通文本、1音素结构
    public var textMode: Int = 0
    
    /// 是否识别静音，默认YES
    public var silentDetectTimeOut: Bool = true
    
    /// 录音音量回调时间，毫秒，默认200ms
    public var minVolumeCallbackTime: Double = 200
    
    /// 识别到静音是否停止本次识别，默认YES
    public var endRecognizeWhenDetectSilenceAutoStop = true
    
    /// 最大静音时间阈值, 超过silenceDetectDuration时间不说话则为静音, 单位:秒
    public var audioFlowSilenceTimeOut: Float = 5.0
    
    /// 识别到静音是否停止本次识别，默认YES
    public var silenceDetectDuration = true
    
    /// 识别引擎
    public var engineModelType: String = "16k_zh"
    
    /// 是否过滤脏词，具体的取值见API文档的filter_dirty参数
    public var filterDirty: Int = 0
    
    /// 过滤语气词具体的取值见API文档的filter_modal参数
    public var filterModal: Int = 0
    
    /// 过滤句末的句号具体的取值见API文档的filter_punc参数
    public var filterPunc: Int = 0
    
    /// 是否进行阿拉伯数字智能转换
    public var convertNumMode: Int?
    
    /// 热词id
    public var hotwordId: String?
    
    /// 自学习模型id
    public var customizationId: String?
    
    /// 语音断句检测阈值，静音时长超过该阈值会被认为断句
    public var vadSilenceTime: Int?
    
    /// 默认1 0：关闭 vad，1：开启 vad。 如果语音分片长度超过60秒，用户需开启 vad。
    public var needvad: Int = 1
    
    /// 是否显示词级别时间戳。0：不显示；1：显示，不包含标点时间戳，2：显示，包含标点时间戳。默认为0。
    public var wordInfo: Int = 0
    
    /// 噪音参数阈值，默认为0，取值范围：[-1,1]
    public var noiseThreshold: Float = 0.0
    
    /// 强制断句功能，取值范围 5000-90000(单位:毫秒），默认值0(不开启)。
    public var maxSpeakTime = 0
    required public init() {}
}

public class BridgeAnswerDetail: SmartCodable {
    public var operateList: Array<String>?
    public var subjectId = ""
    public var text: String?
    public var resultType: String?
    public var path: String?
    
    required public init() {}
}
