//
//  GGXRSA+Extension.swift
//  RSReading
//
//  Created by 高广校 on 2024/7/22.
//

import Foundation
import GGXRSA

extension GGXRSA {
    
    //证书解密
    static func decryptByPrivate(str: String) -> String? {
        guard let privatrFile = Bundle.main.path(forResource: "private_key.p12", ofType: nil) else{
            fatalError("private_key.p12 no exist")
        }
        let rawToken = GGXRSA.decryptString(str, privateKeyPath: privatrFile)
        guard let rawToken else {
            print("解密失败")
            return nil
        }
//        print("解密: \(rawToken)")
        return rawToken
    }
}
