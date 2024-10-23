//
//  RSAudioScope.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/19.
//

import UIKit
//import SwiftyJSON

typealias ZKVoidVoiceScopeModelClosure = (RSBaseVoiceScopeModel) -> Void

class RSAudioScopeManager: NSObject {
    
    //上传音频文件至服务器 获取打分结果
    //    func uploadAudioPath(path:String,text:String,remotePath:String,block:@escaping ZKVoidVoiceScopeModelClosure) {
    //
    //        guard let audioData = path.toFileUrl?.base64FileData else {
    //            block(RSBaseVoiceScopeModel(msg: "没有音频数据", code: -1))
    //            return
    //        }
    //        
    //        uploadAudioData(data: audioData, text: text, remotePath: remotePath,block: block)
    //        
    //    }
    
    //    func uploadAudioData(data:String,text:String,remotePath:String,block:@escaping ZKVoidVoiceScopeModelClosure) {
    //        //拼接data
    //        let operateList = ["scope","oss"]
    //        let data = data
    //        let text = text
    //        let path = remotePath
    //        
    //        let dict : [String : Any] = ["operateList":operateList,
    //                    "voiceData":data,
    //                    "path":path,
    //                    "text":text]
    //        
    //        getVoiceScope(dict: dict, block: block)
    //    }
    
    
    func uploadAudioPath(path:String,speechData:BridgeAnswerDetail?,block:@escaping ZKVoidVoiceScopeModelClosure) {
        guard let audioData = path.toFileUrl?.base64FileData else {
            let scopeError = RSBaseVoiceScopeModel()
            scopeError.msg = "没有音频数据"
            scopeError.code = -1
            scopeError.success = false
            block(scopeError)
            return
        }
        
        var dict: Dictionary<String,Any> = speechData?.toDictionary() ?? [:]
        dict["voiceData"] = audioData
        getVoiceScope(dict: dict, block: block)
    }
    
    func getVoiceScope(dict:Dictionary<String,Any>,block:@escaping ZKVoidVoiceScopeModelClosure) {
        let audioJSON = dict.toJsonString ?? ""
        AudioApiService.share.requestVoiceScope(params: audioJSON) { vsModel in
            block(vsModel)
            //            block(vsModel ?? RSBaseVoiceScopeModel(msg: "接口调用失败", code: -1))
        }
    }
}
