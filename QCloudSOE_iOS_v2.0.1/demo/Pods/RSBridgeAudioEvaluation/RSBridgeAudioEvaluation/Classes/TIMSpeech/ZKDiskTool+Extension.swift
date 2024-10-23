//
//  ZKDiskTool+Extension.swift
//  RSReading
//
//  Created by 高广校 on 2024/6/27.
//

import Foundation
import ZKBaseSwiftProject

//#TODO: 演讲目录
public extension ZKDiskTool {
    
    func createSpeechPath(path: String ,fileExt: String) -> String {
        
        let speechCachePath = (FileManager.cachesPath ?? "") + "/Speech/"
        let filePath = speechCachePath + path.stringByDeletingLastPathComponent
        
        FileManager.createFolder(atPath:filePath)
        
        return filePath + "/" + "\(path.lastPathComponent)" + "." + "\(fileExt)"
    }
}
