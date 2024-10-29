//
//  TencentSOEApi.swift
//  RSAdventureApi
//
//  Created by 高广校 on 2024/10/16.
//

import Foundation
import GXSwiftNetwork
import SmartCodable

public class TencentSOEBaseModel: MSBApiModel {
    
    public var ydata: TencentSOEModel? {
        return TencentSOEModel.deserialize(from: data as? Dictionary<String, Any>)
    }
}

public class TencentSOEModel: SmartCodable {
   
    // 签名
    var skipSign: Bool?
    
    /// 有效时间
    var validTime: Int64 = 60
    
    /// 过期时间
    var expiredTime: Int64?
    
    ///
    var expiration: String?
    
    /// 请求ID
    var requestId: String?
    
    /// 具体参数
    var credentials: TencentSOECredentialsModel?
    
    required public init() {
        
    }
}

public class TencentSOECredentialsModel: SmartCodable {
    
    var appId: String?
    
    public var desc: String?
    
    public var token: String?
    
    public var tmpSecretId: String?
    
    public var tmpSecretKey: String?
    
    required public init() {
        
    }
}


public class TencentSOEApi: MSBApi, MSBDataResponse {

    public typealias Model = TencentSOEModel
    
    init(_ parameters: [String: Any]) {
        super.init(path: "/wap/api/certificate/tencent", parameters: [:], showHud: false)
    }
    
    public static func response(parameters: [String : Any]) async throws -> TencentSOEModel? {
        let api = TencentSOEApi(parameters)
        let reponseResult = try await api.dataTask(with:TencentSOEModel.self)
        return reponseResult.data
//        return try await TencentSOEApi(parameters).request(TencentSOEBaseModel.self)
    }
}
