//
//  SpeechModel.swift
//  RSReading
//
//  Created by 高广校 on 2024/6/27.
//

import Foundation
import SmartCodable
import ZKBaseSwiftProject

//#TODO: Model
public struct TIMSpeechConfigModel: SmartCodable {
    
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
    public init() {}
}

//public struct AudioSpeechModel: SmartCodable {
//    
//    public var TIMConfig: TIMSpeechConfigModel?
//    
//    /// 是否检测录音音量的变化, 开启后sdk会实时回调音量变化
//    public var enableDetectVolume = true
//    
//    /// 是否开启流式传输 默认为true
//    public var stream = true
//    
//    /// 最长录音时长 单位s，最短5s
//    public var duration: Double = 5
//    
//    /// 音频存储路径
//    public var path: String?
//    
//    /// 静音时长 默认6000ms
//    public var vadInterval = 6000
//    
//    /// 是否支持静音检测，默认为true
//    public var vad = true
//    
//    public init() {
//        
//    }
//}
//
//public extension AudioSpeechModel {
//    
//    var fillRecordPath: String {
//        return ZKDiskTool.shared.createAudioRecordpath(path: path ?? "", fileExt: "wav")
//    }
//}
