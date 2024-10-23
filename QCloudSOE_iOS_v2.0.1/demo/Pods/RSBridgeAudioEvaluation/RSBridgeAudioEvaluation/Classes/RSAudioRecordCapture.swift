//
//  RSRServer.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/15.
//

import UIKit
import PTDebugView
import GXAudioRecord
import ZKBaseSwiftProject
//import RSBridgeAudioPlay
//typealias RSRecordColo = (_ time:String) -> Void


public typealias RSAudioRecordCaptureClosure = (Double,Any) -> Void

class RSAudioRecordCapture: NSObject {
    var recordingEnd : ZKStringClosure?
    var speechEvents : RSAudioRecordCaptureClosure?
    var recordManager : AQRecorderManager?
    var recordPath : String = ""
    
    private var timer: Timer?
    
    var duration = 0.0 //录音时长
    
    func startServe(configs:RSBridgeAudioModel) -> Bool {
        
        //录音最大时长
        self.duration = configs.duration
        //实现倒计时功能，根据duration 自动停止倒计时
        self.handleTimeDown()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            self?.handleTimeDown()
        })
        
        //创建文件夹
        //生成录制路径
        self.recordPath = ZKDiskTool.shared.createAudioRecordpath(path: configs.path ?? "", fileExt: "wav")
        //需要实现录音功能，录制结束
        self.recorderMgr.startRecord(withFilePath: self.recordPath)
        
        return true
    }
    
    deinit {
        ZKLog("\(self)-deinit")
    }
    
    func handleTimeDown()  {
        if self.duration <= 0 {
            self.stopServe(type: 1)
            //            self.timer?.invalidate()
            //            self.timer = nil
        } else {
            self.duration = self.duration - 1
            ZKLog("录音倒计时：\(self.duration)")
        }
    }
    
    func stopServe(type:Int)  {
        self.recorderMgr.stopRecord()
        self.timer?.invalidate()
        self.timer = nil
    }
    
    lazy var recorderMgr: AQRecorderManager = {
        let recordm = AQRecorderManager(audioFormatType: .linearPCM, sampleRate: 16000, channels: 1, bitsPerChannel: 16)
        recordm?.aqDataSource = self
        return recordm ?? AQRecorderManager()
    }()
    
}

extension RSAudioRecordCapture : GGXAudioQueueDataSource {
    func recorderManager(_ recorderManager: AQRecorderManager!, andFilePath filePath: String!) {
        
    }
    
    func didOutputAudioPeakPower(_ audioPeak: Float) {
        
    }
    
    func recorderManager(_ recorderManager: AQRecorderManager, didOutputAudiofile sTime: CMTime, andEnd eTime: CMTime, andFilePath filePath: URL?) {
        self.recordingEnd?(self.recordPath)
    }
}
