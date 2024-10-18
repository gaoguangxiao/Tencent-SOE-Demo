//
//  AudioFileTool.swift
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

import Foundation

@objcMembers
public class AudioFileTool: NSObject {
    
    @MainActor public static let share = AudioFileTool()
    
    var audios: Array<String> = []
    
    var current = 0
    
    var orignTxt: String?
    
    func saveTxt(txt: String) -> Void {
        
        orignTxt = txt
        
        let txts = txt.components(separatedBy: "\n")
        if txts.count > 0 {
            current = 0;
            audios.append(contentsOf: txts)
        }
    }
    
    func cureentAudioURL() -> String {
        return audios[current]
    }
    
    func nextAudioURL() -> String {
        current += 1
        if current >= audios.count {
            current = 0
        }
        return audios[current]
    }
    
    func lastAudioURL() -> String {
        current -= 1
        if current == 0 {
            current = audios.count - 1
        }
        return audios[current]
    }
}
