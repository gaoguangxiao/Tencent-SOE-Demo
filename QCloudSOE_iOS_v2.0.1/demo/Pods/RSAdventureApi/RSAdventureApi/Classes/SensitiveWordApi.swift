//
//  SensitiveWordApi.swift
//  RSBridgeAudioConvert
//
//  Created by 高广校 on 2024/8/29.
//

import Foundation
import GXSwiftNetwork
import SmartCodable
import RSBridgeCore
import GGXRSA

public struct SensitiveWordModel: SmartCodable {
    public init () {
        
    }
}

public class SensitiveWordApi: MSBApi, MSBDataResponse {

    public typealias Model = MSBApiModel
    
    init(_ parameters: [String: Any]) {
        super.init(path: "/wap/api/sensitive-word/hide",method: .post,sampleData: parameters.toJsonString ?? "",showHud: false)
    }
    
    public static func response(parameters: [String : Any]) async throws -> MSBApiModel? {
        let api = SensitiveWordApi(parameters)
        let reponseResult = try await api.request(MSBApiModel.self)
        return reponseResult
    }
}
