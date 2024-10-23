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
    enum RecordingEventType: String {
        case evaluation // Score the speech
        case speech     // voice-to-text
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
}
