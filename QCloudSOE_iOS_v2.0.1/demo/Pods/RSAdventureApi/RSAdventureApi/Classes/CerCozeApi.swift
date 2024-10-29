//
//  CerCozeApi.swift
//  RSReading
//
//  Created by 高广校 on 2024/7/24.
//

import Foundation
import GXSwiftNetwork
import SmartCodable
import GGXRSA

public struct CozeResponseModel: SmartCodable {
    public var botId: String?
    public var token: String?
    public var url: String?
    public init(){}
}

//MARK: - ChatError
public enum AiCozeError:Int, CustomNSError {
    case getConfigError
    case getTokenError
    case getBotIDError
    case rsaDecryptTokenError
    case rsaDecryptBotIDError
    
    ///描述ai聊天的
    public static var errorDomain: String {
        return "cozeai"
    }
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case .getTokenError: ["msg": "获取临时token失败"]
        case .rsaDecryptTokenError: ["msg": "RSA解密Token失败"]
        case .getBotIDError:
            ["msg": "获取临时botID失败"]
        case .rsaDecryptBotIDError:
            ["msg": "RSA解密BotID失败"]
        case .getConfigError:
            ["msg": "获取配置失败"]
        }
    }
}

extension AiCozeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .getTokenError: "获取临时token失败"
        case .rsaDecryptTokenError: "RSA解密Token失败"
        case .getBotIDError: "获取临时botID失败"
        case .rsaDecryptBotIDError: "RSA解密BotID失败"
        case .getConfigError:
            "获取配置失败"
        }
    }
}

public class CerCozeApi: MSBApi, MSBDataResponse {
    
    //不可用，后期需要置为可选
    static func response() async throws -> CozeResponseModel {
        return CozeResponseModel()
    }
    
    public typealias Model = CozeResponseModel
    
    init(parameters: [String: Any]) {
        super.init(path: "/wap/api/certificate/coze",parameters: parameters,showHud: false)
    }
    
    public static func response(parameters: [String: Any]) async throws -> CozeResponseModel {
        let api = CerCozeApi(parameters:parameters)
        let reponseResult = try await api.dataTask(with:CozeResponseModel.self)
        guard let botID = reponseResult.data?.botId else { throw AiCozeError.getBotIDError }
        guard let token = reponseResult.data?.token else { throw AiCozeError.getTokenError }

        //2、获取到token
        var result = CozeResponseModel()
        result.url = reponseResult.data?.url
        
        let rawToken = GGXRSA.decryptByPrivate(str: token)
        guard let rawToken else { throw AiCozeError.rsaDecryptTokenError }
        
        let rawBotID = GGXRSA.decryptByPrivate(str: botID)
        guard let rawBotID else { throw AiCozeError.rsaDecryptBotIDError }
        
        result.token = rawToken
        result.botId = rawBotID
        
        //对coze接口信息进行缓存
        return result
    }
}
