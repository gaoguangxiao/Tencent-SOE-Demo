//
//  SpeechActionResponse.swift
//  RSReading
//
//  Created by 高广校 on 2024/6/27.
//

import Foundation

/// speech action
public enum SpeechResponse: String {
    case recognitionEvent // recognize the result
    
    /// recognize the result
    enum RecognitionEventType: String {
        case segment
        case success
        case filter
        case filterError
        case error
    }

    case recordingEvent   // Changes in recording
    
    //Changes in recording
    public enum RecordingEventType: String {
        case evaluation // Score the speech
        case speech     // voice-to-text
        
        case volume
        case timeout
        case match
        case quiet
    }
}

//TODO: RecognitionEventType
public extension SpeechResponse {
    ///
    var segment: String  {
        return RecognitionEventType.segment.rawValue
    }
    
    var success: String {
        return RecognitionEventType.success.rawValue
    }
    
    var filter: String {
        return RecognitionEventType.filter.rawValue
    }
    
    var filterError: String {
        return RecognitionEventType.filterError.rawValue
    }
    
    var error: String {
        return RecognitionEventType.error.rawValue
    }
}

//TODO: RecordingEventType
public extension SpeechResponse {

    var evaluation: String {
        return RecordingEventType.evaluation.rawValue
    }

    var speech: String {
        return RecordingEventType.speech.rawValue
    }
    
    var volume: String {
         RecordingEventType.volume.rawValue
    }
    
    var timeout: String {
        RecordingEventType.timeout.rawValue
    }
    
    var match: String {
         RecordingEventType.match.rawValue
    }
    
    var quiet: String {
         RecordingEventType.quiet.rawValue
    }
}


public typealias EventEvaluationRecording = SpeechResponse.RecordingEventType


//
public protocol AudioEvaluationProtocol: NSObjectProtocol {
    
    /// 录制结束
    func audioRecordEnd(code: Int, msg: String, data: Dictionary<String, Any>)
    
    /// 音量发生变化
    func audioRecordVolume(volume: Int)
    
    /// 静音事件
    func audioRecordSliceDetectTimeOut()
    
    /// 评测超时事件
    func evaluationTimeOut()
    /// 匹配事件
    func evaluationMatch()
    
    /// 打分
    func speechEventEnd(code: Int, msg: String, data: Dictionary<String,Any>)
    
    //
    func evaluationStream(data: Dictionary<String,Any>)
}
 
