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
    lazy var localRecordPlayer: GGXAudioEngine = {
        let pl = GGXAudioEngine()
        return pl
    }()
    
    //
    lazy var localRecordPlayerV2: GXAudioEnginePlayer = {
        let pl = GXAudioEnginePlayer()
        return pl
    }()
    
//    //audioqueue音频
//    lazy var aqPlayer: AQPlayerManager = {
//        let pl = AQPlayerManager()
//        return pl
//    }()
//    
//    lazy var audioPlayer: JHAudioRecorder = {
//        let pl = JHAudioRecorder()
//        return pl
//    }()
    
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
//                    aqPlayer.startPlay(path)
//                audioPlayer.playRecording(with: path)
        
        
        if let filePath = path.toFileUrl {
            try? localRecordPlayer.playpcm(fileURL: filePath)
//            localRecordPlayerV2.playpcm(fileURL: filePath)
            
        }
        
    }
    
    func playAudio() {
        if let url = cureentAudioURL() {
            audioRecordPlayer2.play(url: url)
        } else {
            print("playAudio url error")
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
        guard audios.count > 0 else { return "" }
        current -= 1
        if current <= 0 {
            current = audios.count - 1
        }
        return audios[current]
    }
}
