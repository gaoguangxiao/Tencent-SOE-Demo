//
//  TencentSOE.swift
//  RSReading
//
//  Created by 高广校 on 2024/2/22.
//

import Foundation
import GXSwiftNetwork
import SmartCodable

public class TencentSOEBaseModel: MSBApiModel {
    
    var ydata: TencentSOEModel? {
        return TencentSOEModel.deserialize(from: data as? Dictionary<String, Any>)
    }
}


public class TencentSOEModel: SmartCodable {
    /// 具体参数
    var credentials: TencentSOECredentialsModel?
    
    /// 有效时间
    var validTime: Int64 = 60
    
    /// 过期时间
    var expiredTime: Int64?
    
    ///
    var expiration: String?
    
    /// 请求ID
    var requestId: String?
    
    required public init() {
        
    }
}

public class TencentSOECredentialsModel: SmartCodable {
    
    var appId: String?
    
    var skipSign: Bool?
    
    public var desc: String?
    
    public var token: String?
    
    public var tmpSecretId: String?
    
    public var tmpSecretKey: String?
    
    required public init() {
        
    }
}


public typealias ClosuretencentSOE = (_ code: Int,_ data: TencentSOECredentialsModel) -> Void

public class TencentSOE: NSObject {
    
    /// Refresh the request key three times by default
    public var reloadTIMTokenCount = 3
    
    public func startRecord(block: @escaping ClosuretencentSOE) {
        Task { 
            let (code, data) = await startRecord()
            block(code,data)
        }
    }
    
    public func startRecord() async -> (Int,TencentSOECredentialsModel) {
        //获取TIM凭证过期时间
        let takeTime = Date.milliStamp/1000
        let durationSeconds: Int64 = UserDefaults.DurationSeconds <= 60 ? 30 : 60 //空白时间
        if let expiredTime = UserDefaults.ExpiredTime,
           takeTime + durationSeconds < expiredTime ,
           let Credentials = UserDefaults.Credentials,
           let CredentialsModel = TencentSOECredentialsModel.deserialize(from: Credentials){
            return (0,CredentialsModel)
        } else {
            //            ZKLog("更新TIM临时密钥")
            guard reloadTIMTokenCount > 0 else {
                let credentialsModel = TencentSOECredentialsModel()
                credentialsModel.desc = "密钥重试次数超过限制"
                return (-2,credentialsModel)
            }
            reloadTIMTokenCount = reloadTIMTokenCount - 1
            return await withUnsafeContinuation { result in
                AudioApiService.share.configsTIM(params: [:]) { configModel in
                    let b = configModel.success
                    if let cd = configModel.ydata, let cre = cd.credentials, b == true {
                        UserDefaults.ExpiredTime = cd.expiredTime
                        UserDefaults.DurationSeconds = cd.validTime
                        UserDefaults.Credentials = cre.toJSONString()
                        result.resume(with: .success((0,cre)))
                    } else {
                        let credentialsModel = TencentSOECredentialsModel()
                        credentialsModel.desc = "获取临时密钥失败"
                        result.resume(with: .success((-1,credentialsModel)))
                    }
                }
            }
        }
    }
    
    public func resetRecord(block: @escaping ClosuretencentSOE) {
        ///清理临时token
        self.clearCredentials()
        
        self.startRecord(block: block)
    }
    
    public func resetRecord() async -> (Int,TencentSOECredentialsModel) {
        ///清理临时token
        self.clearCredentials()
        
        let (code, data) = await startRecord()
        
        return (code, data)
    }
    
    func clearCredentials() {
        UserDefaults.ExpiredTime = 0
        UserDefaults.Credentials = ""
    }
}

/**
 //获取TIM凭证过期时间
 //计算凭证是否失效 expiredTime【到期时间】 - 存储时间 > 失效
 //获取过期时间
 let takeTime = Date.milliStamp/1000
 let durationSeconds: Int64 = UserDefaults.DurationSeconds <= 60 ? 30 : 60 //空白时间
 //        ZKLog("当前时间:\(takeTime)，失效时间:\(UserDefaults.ExpiredTime ?? 0)，距离失效还有\((UserDefaults.ExpiredTime ?? 0) - takeTime)秒")
 if let expiredTime = UserDefaults.ExpiredTime,
    takeTime + durationSeconds < expiredTime ,
    let Credentials = UserDefaults.Credentials,
    let CredentialsModel = TencentSOECredentialsModel.deserialize(from: Credentials){
     block(0,CredentialsModel)
     
 } else {
     //            ZKLog("更新TIM临时密钥")
     guard reloadTIMTokenCount > 0 else {
         let credentialsModel = TencentSOECredentialsModel()
         credentialsModel.desc = "密钥重试次数超过限制"
         block(-2,credentialsModel)
         return
     }
     reloadTIMTokenCount = reloadTIMTokenCount - 1
     
     AudioApiService.share.configsTIM(params: [:]) { configModel in
         
         let b = configModel.success
         if let cd = configModel.ydata, let cre = cd.credentials, b == true {
             
             UserDefaults.ExpiredTime = cd.expiredTime
             UserDefaults.DurationSeconds = cd.validTime
             
             UserDefaults.Credentials = cre.toJSONString()
             
             block(0,cre)
         } else {
             let credentialsModel = TencentSOECredentialsModel()
             credentialsModel.desc = "获取临时密钥失败"
             block(-1,TencentSOECredentialsModel())
         }
     }
 }
 */
