//
//  AudioApiService.swift
//  RSReading
//
//  Created by 高广校 on 2023/9/19.
//

import UIKit
import GXSwiftNetwork
import SmartCodable

class RSBaseVoiceScopeModel: MSBApiModel {
//    var data: RSVoiceScopeModel?
    var ydata: RSVoiceScopeModel? {
        return RSVoiceScopeModel.deserialize(from: data as? Dictionary<String, Any>)
    }
    
//    required init() {
//        
//    }
//    
//    required init(from decoder: any Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
    //    解析失败
//    init(msg: String, code: Int, success: Bool = false) {
//        super.init()
//        self.msg = msg
//        self.code = code
//        self.success = success
//    }
    

//    required init() {
//        super.init()
//        fatalError("init() has not been implemented")
//    }
    
//    required init(from decoder: any Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
    
//    required init() {
//        fatalError("init() has not been implemented")
//    }
}

class RSVoiceScopeModel: SmartCodable {
    var fileUrl : String = ""
    var score : Float = 0.0
    
    required public init(){}
}

class RSAudioApi: MSBApi {
    
    class VoiceScopeApi: RSAudioApi {
        init(paras : String) {
            super.init(path: "/wap/api/voice/scope",method: .post,sampleData: paras,showErrorMsg: false,showHud: false)
        }
    }
    
    class certificateApi: RSAudioApi{
        init(paras : [String: Any]) {
            super.init(path:"/wap/api/certificate/tencent",
                       parameters: paras,showErrorMsg: false,showHud: false)
        }
    }
}


public class AudioApiService: NSObject {
    static let share : AudioApiService = {
        return AudioApiService()
    }()
    
    func requestVoiceScope(params:String,
                           closure: @escaping ((RSBaseVoiceScopeModel) -> ())) {
        let api = RSAudioApi.VoiceScopeApi(paras: params)
        api.request { (result: RSBaseVoiceScopeModel) in
            closure(result)
        } onFailure: { e in
            let scopeError = RSBaseVoiceScopeModel()
            scopeError.msg = e.msg
            scopeError.code = e.code
            scopeError.success = false
            closure(scopeError)
        }
    }
    
    //MARK: 获取TIM配置
    public func configsTIM(params: [String: Any],closure: @escaping ((TencentSOEBaseModel) -> ())) {
        let api = RSAudioApi.certificateApi(paras: params)
        api.request { (result: TencentSOEBaseModel) in
            closure(result)
        } onFailure: { e in
            let bm = TencentSOEBaseModel()
            bm.code = e.code
            closure(bm)
        }
    }
}
