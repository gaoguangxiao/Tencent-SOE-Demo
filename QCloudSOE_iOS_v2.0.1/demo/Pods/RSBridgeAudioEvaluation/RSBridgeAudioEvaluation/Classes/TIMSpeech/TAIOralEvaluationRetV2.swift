//
//  TAIOralEvaluationRetV2.swift
//  RSBridgeAudioEvaluation
//
//  Created by 高广校 on 2024/11/18.
//

import Foundation
import SmartCodable


@objcMembers
public class Tone: NSObject, SmartCodable {

    public var Valid: Bool?
    
    public required override init() {
        
    }
}


@objcMembers
public class TAIOralEvaluationPhoneInfoV2: NSObject, SmartCodable {
    //当前音节语音起始时间点，单位为ms
    public var MemBeginTime: Int?
    
    //当前音节语音终止时间点，单位为ms
    public var MemEndTime: Int?
    
    //单词发音准确度，取值范围[-1, 100]，当取-1时指完全不匹配
    public var PronAccuracy: Float?
    
    //单词发音流利度，取值范围[0, 1]
    public var PronFluency: Float?
    
    public required override init() {
        
    }
}


@objcMembers
public class TAIOralEvaluationWordV2: NSObject, SmartCodable {
    
    //当前词
    public var Word: String?
    
    //参考词
    public var ReferenceWord: String?
    
    //音节评估详情
    public var PhoneInfos: [TAIOralEvaluationPhoneInfoV2]?
    
    public required override init() {
        
    }
}


@objcMembers
public class TAIOralEvaluationRetV2: NSObject, SmartCodable {
    
    //建议评分，取值范围[0,100]
    //评分方式为建议评分 = 准确度（PronAccuracyfloat）× 完整度（PronCompletionfloat）×（2 - 完整度（PronCompletionfloat））
    //如若评分策略不符合请参考Words数组中的详细分数自定义评分逻辑。
    public var SuggestedScore: Float = 0.0
    
    //单词发音准确度，取值范围[-1, 100]，当取-1时指完全不匹配
    public var PronAccuracy: Float = 0.0
    
    //单词发音流利度，取值范围[0, 1]
    public var PronFluency: Float = 0.0
    
    // 发音完整度，取值范围[0, 1]，当为词模式时，取值无意义
    public var PronCompletion: Float = 0.0
    
    public var Words: [TAIOralEvaluationWordV2]?
    
    // 句子序号，在段落、自由说模式下有效，表示断句序号，最后的综合结果的为-1.
    public var sentenceID: Int = 0
    
    // 单词发音流利度，取值范围[0, 1]
    public var RefTextId: Int = 0
    
    public required override init() {
        
    }
}

@objcMembers
public class TAIOralEvaluationDataV2: NSObject, SmartCodable {
    
    // 是否结束
    public var bEnd: Bool = false
    
    // 流式完成-RSBridgeAudioModel中stream必须为true
    public var streamFinish: Bool = false
    
    // 音频评测数据
    public var evaluationValue: String = ""
    
    /// 音频数据
    public var audio: Data?
    
    // 音频base64
    public var audioBase64: String?
    
    // 音频时长
    public var duration: Float64 = 0.0
    
    // 音频评测的数据
    public var result: TAIOralEvaluationRetV2?
    
    public required override init() {}
}

@objcMembers
public class TAIOralEvaluationWordBase: NSObject, SmartCodable {
    
    public var code: Int?
    
    public var message: String?
    
    public var voice_id: String?
    
    public var result: TAIOralEvaluationRetV2?
    
    public required override init() {}
    
    public static func objectValues(_ value: String) -> TAIOralEvaluationWordBase? {
        return TAIOralEvaluationWordBase.deserialize(from: value)
    }
}

//class S {
//    var SuggestedScore: float?
//}
