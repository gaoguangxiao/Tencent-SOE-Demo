//
//  TXSpeechTool.swift
//  RSSpeech
//
//  Created by 高广校 on 2024/6/14.
//

import Foundation
import QCloudRealTime
import SwiftUI
import AVFAudio
import GGXAppleSpeech
import Combine
import PTDebugView
import RSAdventureApi

//struct Config {
//    static var appID = "1321939176";
//}


@objcMembers
public class TXSpeechTool: NSObject, RSSpeechToolProtocol, ObservableObject {
    
    @Published public var recognizeStatus: GGXAppleSpeech.LKSpeechRecognizerStatus = .None
    
    /// 测试结果
    @Published public var recognizeTxt: String = ""
    
    /// 音量
    @Published public var volume: Float = 0.0
    
    var recognizer: QCloudRealTimeRecognizer? = nil;
    
    let recordSOE = TencentSOE()
    
    var delegate: QCloudRealTimeRecognizerDelegate?
    
    /// 要识别的数据模型
    public func startSpeech() {
//        Task {
//            recordSOE.reloadTIMTokenCount = 3
//            let (_, data) = await recordSOE.startRecord()
//            startSpeech(credentials: data)
//        }
    }
    
    func startSpeech(credentials: TencentSOECredentialsModel) {
        guard let tmpSecretId = credentials.tmpSecretId ,
              let tmpSecretKey = credentials.tmpSecretKey,
              let token = credentials.token else {
            return
        }
        let config = QCloudConfig(appId: "1321939176", secretId: tmpSecretId, secretKey: tmpSecretKey,token: token, projectId: 0)
        config.sliceTime = 40;
        config.enableDetectVolume = false;
        config.endRecognizeWhenDetectSilence = false;
        config.requestTimeout = 10;
        config.engineType = "16k_en";
//        config.enableDetectVolume = true
        //            self.speechObservation.recognizeTxt = "";
        self.recognizer =  QCloudRealTimeRecognizer.init(config: config);
        //        self.recognizer?.enableDebugLog(true);
        self.recognizer?.delegate = self;
        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            
//            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
//            try audioSession.setMode(AVAudioSession.Mode.measurement)
//            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
//            
//        } catch let error {
//            
//            print("audioSession properties weren't set because of an error:\(error.localizedDescription)")
//            self.recognizeStatus = .recognizeError
//            //            recognizerResult?(.recognizeError,self.bestText,self.speakText,error)
//            
//            return
//        }
        
        self.recognizeStatus = .recognizing;
        
        recognizer?.start();
    }
    
    public func endSpeech() {
        
        self.recognizer?.stop();
        
        recognizeStatus = .None
    }
}

extension TXSpeechTool: QCloudRealTimeRecognizerDelegate {
    
    public func realTimeRecognizer(onSliceRecognize recognizer: QCloudRealTimeRecognizer, result: QCloudRealTimeResult) {
        self.recognizeTxt = result.recognizedText;
        ZKLog("recognizedText：\(result.recognizedText)")
        self.delegate?.realTimeRecognizer(onSliceRecognize: recognizer, result: result)
    }
    
    public func realTimeRecognizer(onSegmentSuccessRecognize recognizer: QCloudRealTimeRecognizer, result: QCloudRealTimeResult) {
    }
    
    /// 一次识别成功回调
    public func realTimeRecognizerDidFinish(_ recognizer: QCloudRealTimeRecognizer, result: String) {
        //        self.btn_text = "开始识别";
        self.recognizeStatus = .None;//
        ZKLog("一次识别的回调：\(result)")
        self.delegate?.realTimeRecognizerDidFinish?(recognizer, result: result)
    }
    
    
    //一次识别失败回调
    public func realTimeRecognizerDidError(_ recognizer: QCloudRealTimeRecognizer, result: QCloudRealTimeResult) {
        self.recognizeStatus = .None;//
        //        self.btn_text = "开始识别";
        //        self.result = result.clientErrMessage;
        self.recognizeTxt = result.clientErrMessage;
        ZKWLog.Log("realTimeRecognizerDidError: \(result)")
    }
    
    public func realTimeRecognizer(onFlowRecognizeStart recognizer: QCloudRealTimeRecognizer, voiceId: String, seq: Int) {
        //        self.btn_text = "停止识别";//running
        self.recognizeStatus = .recognizing;
    }
    
//    public func realTimeRecognizerDidUpdateVolume(_ recognizer: QCloudRealTimeRecognizer, volume: Float) {
//        ZKWLog.Log("realTimeRecognizerDidUpdateVolumeDB: \(volume)")
//    }
    
    public func realTimeRecognizerDidUpdateVolumeDB(_ recognizer: QCloudRealTimeRecognizer, volume: Float) {
        self.volume = volume
        ZKWLog.Log("realTimeRecognizerDidUpdateVolumeDB: \(volume)")
    }
    
    public func realTimeRecgnizerLogOutPut(withLog log: String) {
//        ZKLog("realTimeRecgnizerLogOutPut: \(log)")
    }
}
