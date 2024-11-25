//
//  LKSpeechRecognizer.swift
//  demo-speech
//
//  Created by 高广校 on 2024/5/30.
//

import UIKit
import Foundation
import Speech
import AVFoundation
import TKPermissionKit
/// 是否为模拟器
var IS_Simulator:Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
}


public class LKSpeechRecognizer: NSObject {
    
    public static let share = LKSpeechRecognizer()
    
    ///status 状态  baseText：识别结果， speechText：识别校验后的结果
    public typealias LKSpeechRecognizerResult = (_ status:LKSpeechRecognizerStatus ,
                                          _ baseText:String?,
                                          _ speechText:String?,
                                          _ error:Error?) -> Void
    
    private var recognizerResult: LKSpeechRecognizerResult? = nil
    
    private var bestText:String? = ""
    private var speakText:String? = ""
    
    //静音间隔时间 默认3s
    var muteTime:TimeInterval = 3.0
    
    public var recognizerStatus:LKSpeechRecognizerStatus = .None
    
    private var timer:Timer? = nil
    private var isHaveInput:Bool = false
    
    /// 语音识别任务管理器
    private var speechTask: SFSpeechRecognitionTask?
    
    // 语音识别器
    private var speechRequest = SFSpeechAudioBufferRecognitionRequest()
    
    private var speechRecognizer:SFSpeechRecognizer = {
        let locale = Locale(identifier: "zh_CN")
        //中文 zh_CN
        //英文 en_US
        //NSLocale.current
        let sRecognizer:SFSpeechRecognizer = SFSpeechRecognizer(locale: locale)!//设置识别语种跟随系统语言
        return sRecognizer
    }()
    
    private var audioEngine:AVAudioEngine = {
        let aEngine: AVAudioEngine = AVAudioEngine()
        return aEngine
    }()
    
    public override init() {
        super.init()
        
        self.speechRecognizer.delegate = self
        //请求权限
        if IS_Simulator == false {
            //checkAuthorized()
        } else {
            print("模拟器不支持")
        }
        
    }
}

//MARK: -
public extension LKSpeechRecognizer {
    
    //开始识别
    func startRecordSpeech() {
        
        bestText = nil
        speakText = nil
        
        //请求授权
        requestSpeechAuthorization {[weak self] authorizeStatus in
            guard let self else { return }
            if authorizeStatus == false {//用户未授权
                recognizerStatus = .noAuthorize
                recognizerResult?(.noAuthorize,nil,nil,nil)
                return
            }
//            ZKSLog("requestRecordSpeech")
            requestRecordSpeech()
        }
    }
    
    
    func requestRecordSpeech() {
        
        if speechTask != nil {
            speechTask?.cancel()
        }
        
//        if speechTask?.state == .running {
//            stopRecordSpeech()
//        }
        
        bestText = nil
        speakText = nil
        
        //AVAudioSession:音频会话，主要用来管理音频设置与硬件交互
        //配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            
        } catch let error {
            
            print("audioSession properties weren't set because of an error:\(error.localizedDescription)")
            recognizerStatus = .recognizeError
            recognizerResult?(.recognizeError,self.bestText,self.speakText,error)
            
            return
        }
        
        
//        speechRequest = SFSpeechAudioBufferRecognitionRequest()
//        speechRequest?.contextualStrings = ["data","bank","databank"]
//        speechRequest?.taskHint = .search
        speechRequest.shouldReportPartialResults = true
//        speechRecognizer.recognitionTask(with: speechRequest!, delegate: self)
        
        speechTask = speechRecognizer.recognitionTask(with: speechRequest, resultHandler: { [weak self] (result, error) in
            
            guard let self else { return }
            
            var isFinished = false
            isFinished = result?.isFinal ?? false
            
            if let result {//有音频输入
                
                self.isHaveInput = true
                
                let bestString = result.bestTranscription.formattedString
//                print("bestString:\(bestString)")

                self.bestText = bestString
                self.speakText = bestString
                
                self.recognizerResult?(.recognizing,self.bestText,self.speakText,nil)
                
                //一次识别结束后开启静默监测，2s内没有声音做结束逻辑处理
//                self.startDetectionSpeech()
            }
            
            if error != nil || isFinished == true {

                if isFinished == true {//结束
                    self.recognizerStatus = .None
                    self.recognizerResult?(.None,self.bestText,self.speakText,nil)
                    print("转换结束了")
                }
//                
//                if let error = error {//报错了
//                    
//                    if self.recognizerStatus != .recognizeMuteTimeout {
//                        self.recognizerStatus = .recognizeError
//                        self.recognizerResult?(.recognizeError,self.bestText,self.speakText,error)
//                    }
//                }
            }
        })
        
        let inputNode:AVAudioInputNode? = audioEngine.inputNode
        //配置麦克风输入
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        if let inputNode = inputNode {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { [weak self] buffer, when in
                guard let self = self else { return }
//                if let speechRequest = self.speechRequest {
                    //将音频流拼接到self.speechRequest
                    speechRequest.append(buffer)
                    self.isHaveInput = false
//                }
            })
        }
        
        //准备
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
            self.recognizerStatus = .recognizing
            self.recognizerResult?(.recognizing,self.bestText,self.speakText,nil)
        } catch let error {
            self.recognizerStatus = .recognizeError
            print("audioEngine couldn't start because of an error:\(error.localizedDescription)")
        }
    }
    
    //MARK: - 关闭录音识别
    func stopRecordSpeech() {
        
        stopDetectionSpeech()
        
//        if audioEngine.inputNode.numberOfInputs > 0 {
//            audioEngine.inputNode.removeTap(onBus: 0)
//        }
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioEngine.reset()
        
        speechRequest.endAudio()
        
        speechTask?.cancel()
        speechTask?.finish()
        speechTask = nil
        
        recognizerStatus = .recognizeFinished
        recognizerResult?(.recognizeFinished,self.bestText,self.speakText,nil)
        
        print("录音关闭")
    }
    
    //MARK: - 状态及结果回调
    func recognizerResult(_ completion: LKSpeechRecognizerResult?) {
        recognizerResult = completion
    }
}

//MARK: - 静音监测
extension LKSpeechRecognizer {
    
    private func startDetectionSpeech(){
        
        if let timer = timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        
        NSLog("开始计时检测")
        timer = Timer.scheduledTimer(timeInterval: muteTime, target: self, selector: #selector(self.didFinishSpeech), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    private func stopDetectionSpeech() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            NSLog("结束计时检测")
        }
    }
    
    @objc private func didFinishSpeech() {
        
        print("音频检测------")
        
        if isHaveInput == false {
            
            print("检测到\(muteTime)s内没有说话")
            
            stopDetectionSpeech()
            
            if audioEngine.inputNode.numberOfInputs > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            audioEngine.stop()
            audioEngine.reset()
            
            speechRequest.endAudio()
            
            speechTask?.cancel()
            
            recognizerStatus = .recognizeMuteTimeout
            recognizerResult?(.recognizeMuteTimeout,self.bestText,self.speakText,nil)
        }
    }
}

//MARK: - SFSpeechRecognizerDelegate
extension LKSpeechRecognizer: SFSpeechRecognizerDelegate {
    //录音发生变化
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("音频转化发生变化：\(speechRecognizer) - \(available)")
    }
}

//MARK: - SFSpeechRecognitionTaskDelegate
extension LKSpeechRecognizer: SFSpeechRecognitionTaskDelegate {
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("speechRecognitionTask\(task) - \(successfully)")
    }
    
    // Called when the task first detects speech in the source audio
//    当任务首次检测到源音频中的语音时调用
    public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }

    
    // Called for all recognitions, including non-final hypothesis
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription)
    {
        print("speechRecognitionTask")
    }
    
    // Called only for final recognitions of utterances. No more about the utterance will be reported
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        
    }

    
    // Called when the task is no longer accepting new audio but may be finishing final processing
    public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        
    }

    
    // Called when the task has been cancelled, either by client app, the user, or the system
    public func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        
    }

    
    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
//    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
//        
//    }
}

//申请权限
extension LKSpeechRecognizer {
    
    //MARK: 检测权限
    func checkAuthorized() {
        requestSpeechAuthorization { authorizeStatus in
            
        }
    }
    
    //MARK: - 申请语音识别权限
    func requestSpeechAuthorization(authorize: @escaping (Bool)-> Void ) {
        
        if IS_Simulator == true {
            authorize(false)
            print("模拟器不支持")
            return
        }
        
        TKPermissionSpeech.auth(withAlert: true) { isAuth in
            authorize(isAuth)
        }
    }
    
}
