//
//  CerMicrosoftApi.swift
//  RSReading
//
//  Created by 高广校 on 2024/7/24.
//

import Foundation
import SmartCodable
import GXSwiftNetwork
import GGXRSA
import RSBridgeCore

public struct SpeechResponseModel: SmartCodable {
    public var key: String?
    public var region: String?
    public init(){}
}

//MARK: - SynthesisError
public enum CerMicrosoftApiError: Int, BridgeErrorProtocol {
    case dataError   = 1
    case getKeyError
    case getRegionError
    case rsaDecryptKeyError
    case rsaDecryptRegionError

    public var errorString: String {
        switch self {
        case .getKeyError: "获取`key`失败"
        case .getRegionError: "获取`region`失败"
        case .rsaDecryptKeyError: "RSA解密`key`失败"
        case .rsaDecryptRegionError: "RSA解密`region`失败"
        case .dataError:
            "数据不对"
        }
    }
}

public class CerMicrosoftApi: MSBApi, MSBDataResponse {
    public typealias Model = SpeechResponseModel
    
    init() {
        super.init(path: "/wap/api/certificate/microsoft",showHud: false)
    }
    
    public static func response() async throws -> SpeechResponseModel {
        let api = CerMicrosoftApi()
        let reponseResult = try await api.dataTask(with: SpeechResponseModel.self)
        guard let key = reponseResult.data?.key,
              let region = reponseResult.data?.region else {
            throw BridgeRespError<CerMicrosoftApiError>.type(.dataError)
        }

        //2、获取到token
        var result = SpeechResponseModel()
        
        let rawKey = GGXRSA.decryptByPrivate(str: key)
        guard let rawKey else { throw BridgeRespError<CerMicrosoftApiError>.type(.rsaDecryptKeyError) }
        
        let rawRegion = GGXRSA.decryptByPrivate(str: region)
        guard let rawRegion else { throw BridgeRespError<CerMicrosoftApiError>.type(.rsaDecryptRegionError) }
        
        result.key = rawKey
//        result.key = RSConfig.errorSub
        result.region = rawRegion
//        print("解密: \(token)")
        return result
    }
}
