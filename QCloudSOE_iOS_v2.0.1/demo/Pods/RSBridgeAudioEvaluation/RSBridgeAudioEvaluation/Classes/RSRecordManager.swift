//
//  RSRecordManager.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/18.
//

import UIKit
import RSBridgeCore
import ZKBaseSwiftProject

public class RSRecordManager: NSObject {
    
    private var _speechServer : RSAudioRecordCapture? = nil
    
    public func recordAudio(callbackId:Int,audioModel:RSBridgeAudioModel,block: @escaping JSHandleModelCallBlock) {
        
        let path = audioModel.path ?? ""
//        _ = audioModel.answerDetail?.text ?? ""
        let score = audioModel.score
        
        self._speechServer = RSAudioRecordCapture()
        
        if self._speechServer?.startServe(configs: audioModel) ?? false {
            block(CallWeb(callbackId))
            self._speechServer?.recordingEnd = { s in
//                ZKLog("录音路径\(s)")
                //计算录音时长
                let duration = ZKAudioTool.audioDurationFromUrl(url: s)
//                ZKLog("录音时长\(duration)")
                let rEndbody = RSBridgeModel()
                rEndbody.action = "recordingEnd"
                let data = ["path": path,
                            "localUrl":path + ".wav",
                            "duration": duration.toFloor(2)]
                rEndbody.data = data as Dictionary<String, Any>
                block(rEndbody)
                //判断是否需要打分
                if score {
                    //打分上传接口
                    let vscopeManager = RSAudioScopeManager()
                    vscopeManager.uploadAudioPath(path: s, speechData: audioModel.speechData) {vsc in
                        var reqData : [String:Any] = ["path": path,
                                       "scoreType": audioModel.scoreType]
                        reqData["event"] = vsc.success ? "success" : "error"
                        if let vsData = vsc.ydata {
                            reqData["data"] = ["fileUrl":vsData.fileUrl,
                                               "score":vsData.score] as [String : Any]
                        }
                        let speechBody = RSBridgeModel()
                        speechBody.data = reqData
                        speechBody.action = "speechEvent"
                        block(speechBody)
                    }
                }
                self._speechServer = nil
            }
        } else {
            self._speechServer = nil
            block(CallWeb(callbackId, code: 1,msg: "初始化录制工具失败"))
        }
    }
    
    public func stopRecord(callbackId: Int ,block: @escaping JSHandleModelCallBlock) {
        self._speechServer?.stopServe(type: 1)
        block(CallWeb(callbackId: callbackId))
    }
    
    
}
