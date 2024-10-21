//
//  AudioFileTool.swift
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

import Foundation
import GXAudioPlay

@objcMembers
public class AudioFileTool: NSObject {
    
    @MainActor public static let share = AudioFileTool()
    
    var audios: Array<String> = []
    
    var current = 0
    
    var orignTxt: String?
    
    lazy var audioRecordPlayer2: PTAudioPlayer = {
        let pl = PTAudioPlayer()
        return pl
    }()
    
    //本地音频
    lazy var localRecordPlayer: GXAudioEnginePlayer = {
        let pl = GXAudioEnginePlayer()
        return pl
    }()
    
    func clearTxt() {
        audios.removeAll()
    }
    
    func saveTxt(txt: String) -> Void {
        
        orignTxt = txt
        
        let txts = txt.components(separatedBy: "\n")
        if txts.count > 0 {
            current = 0;
            audios.append(contentsOf: txts)
        }
    }
    
    func cureentAudioURL() -> String? {
        guard audios.count > 0 else { return nil }
        return audios[current]
    }
    
    func playLocal(path: String) {
        if let filePath = path.toUrl {
            localRecordPlayer.play(fileURL: filePath)
        }
        
    }
    
    func playAudio() {
        if let url = cureentAudioURL() {
            audioRecordPlayer2.play(url: url)
        }
    }
    
    
    func playAudioWithAV(path: String) {
        audioRecordPlayer2.play(url: path)
    }
    
    func nextAudioURL() -> String {
        guard audios.count > 0 else { return "" }
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
