//
//  RSAudioEvaluationManagerV2.swift
//  RSChatRobot
//
//  Created by 高广校 on 2024/10/17.
//

import Foundation
import RSBridgeCore
import RSBridgeAudioEvaluation
//import PTDebugView
import ZKBaseSwiftProject

@objcMembers
public class RSAudioEvaluationManagerV2: NSObject {
        
//    let recordSOE = TencentSOE()
    
    var config: TAIOralConfig?
    
    let source: TAIOralDataSource = RecordDataSource()
    
    var _ctl: TAIOralController?
//    id<TAIOralDataSource> _source;
    
    private var bridgeEvaluationModel: RSBridgeAudioModel?
    
    private var recordPath: String?
    
    public func endRecordingV2() {
        _ctl?.stop()
    }
    
    public func startV2(audioModel: RSBridgeAudioModel,
                       cerData: TencentSOECredentialsModel) async throws -> Bool {
        
        guard let text = audioModel.speechData?.text else {
            throw BridgeRespError<BridgeAudioError>.type(.textNotFound)
        }
        
        //        let duration = audioModel.duration
        
        // 是否开启流式判卷
        //        audioModel.stream = false
        
        let stream = audioModel.stream
        
        // 静音时长
        let vadInterval = audioModel.vadInterval
    
        // 是否开启静音
        let vad = audioModel.vad
        
        //获取采用何种字符替换
        let replaceMenet = " "
        let processedText = if let str = text.replace(pattern: "[^a-zA-Z]", replacement: replaceMenet) {
            str
        } else {
            text
        }
        
        let components = processedText.split(separator: " ")
        self.bridgeEvaluationModel?.wordsCount = components.count
        self.bridgeEvaluationModel?.lastWord = components.last.map(String.init)
        
        //        ZKLog("单词长度：\(self.bridgeEvaluationModel?.wordsCount ?? 0)")
        //        ZKLog("最后一个单词：\(self.bridgeEvaluationModel?.lastWord ?? "")")
        
        //录音配置
        config = TAIOralConfig()
       
        config?.appID = "1321939176"
        guard let token = cerData.token  else { return false }
        config?.token = token
        
        guard let secretId = cerData.tmpSecretId  else { return false }
        config?.secretID = secretId
        
        guard let tmpSecretKey = cerData.tmpSecretKey  else { return false }
        config?.secretKey = tmpSecretKey
        //流式传输
        if stream {
            config?.setApiParam(kTAISentenceInfoEnabled, value: "\(stream)")
        }
        
        config?.setApiParam(kTAIServerEngineType, value: "16k_en")
        // 评测模式
        if let evelModel = audioModel.TIMConfig?.evalMode {
            config?.setApiParam(kTAIEvalMode, value: "\(evelModel)")
        } else {
            config?.setApiParam(kTAIEvalMode, value: "1")
        }
        
        //苛刻度设置
        if let scoreCoeff = audioModel.TIMConfig?.scoreCoeff {
            config?.setApiParam(kTAIScoreCoeff, value: "\(scoreCoeff)")
        } else {
            config?.setApiParam(kTAIScoreCoeff, value: "1.0")
        }
        
        // 评测文本
        if let refText = audioModel.TIMConfig?.refText {
            config?.setApiParam(kTAIRefText, value: refText)
        } else {
            config?.setApiParam(kTAIRefText, value: text)
        }
        
        // 文本模式
        if let textMode = audioModel.TIMConfig?.textMode {
            config?.setApiParam(kTAITextMode, value: "\(textMode)")
        } else {
            config?.setApiParam(kTAITextMode, value: "0")
            
        }
//        [config setApiParam:kTAISentenceInfoEnabled value:[@(self.sentenceInfoSeg.selectedSegmentIndex) stringValue]];
//        if (self->_keywordText.text.length) {
//            [config setApiParam:kTAIKeyword value:self->_keywordText.text];
//        }
        
        self.recordPath = ZKDiskTool.shared.createRecordAudioPathAndRemoveOldPath(path: audioModel.path ?? "", fileExt: "pcm")
        config?.audioFile =  self.recordPath;
        
//        > 0生效,单位为ms,默认为0
        if vad {
            config?.vadInterval = Int32(vadInterval)
        }
        
        config?.connectTimeout = 3000;
        
//        _source = RecordDataSource()
//        guard let sou = _source else { return  false }
        
        let _ctl = config?.build(source, listener: self)
        return true
    }

}

extension RSAudioEvaluationManagerV2: TAIOralListener {
    
    public func onFinish() {
        
    }
    
    public func onError(_ error: any Error) {
        
    }
    
    public func onMessage(_ value: String) {
        
    }
    
    public func onVad(_ value: Bool) {
        
    }
    
    public func onVolume(_ value: Int32) {
        
    }
    
    public func onLog(_ value: String, level: Int32) {
        
    }
}
