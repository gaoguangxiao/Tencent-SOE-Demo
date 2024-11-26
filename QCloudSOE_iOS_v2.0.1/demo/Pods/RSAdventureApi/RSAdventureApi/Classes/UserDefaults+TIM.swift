//
//  UserDefaults+TIM.swift
//  RSReading
//
//  Created by 高广校 on 2024/2/22.
//

//import Foundation
import GGXSwiftExtension

extension Keys {
    static let TakeTime: String = "TakeTime"
    static let DurationSeconds: String = "DurationSeconds"
    static let ExpiredTime: String = "ExpiredTime"
    static let Credentials: String = "Credentials"
}

public extension UserDefaults {
    ///TIM 凭证开始 生效时间
//    @UserDefaultWrapper(key: Keys.TakeTime, defaultValue: 0)
//    static var TakeTime: Int?
    
    ///TIM 凭证开始 有效期
    @UserDefaultWrapper(key: Keys.DurationSeconds, defaultValue: 0)
    static var DurationSeconds: Int64
    
    ///TIM 凭证过期时间
    @UserDefaultWrapper(key: Keys.ExpiredTime, defaultValue: 0)
    static var ExpiredTime: Int64?
    
    /// TIM Credentials具体数据
    @UserDefaultWrapper(key: Keys.Credentials, defaultValue: "")
    static var Credentials: String?
}
