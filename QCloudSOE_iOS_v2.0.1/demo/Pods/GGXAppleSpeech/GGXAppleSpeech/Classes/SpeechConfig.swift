//
//  SpeechConfig.swift
//  RSSpeech
//
//  Created by 高广校 on 2024/6/14.
//

import Foundation
import SwiftUI

public protocol RSSpeechToolProtocol {
    
    var recognizeStatus: LKSpeechRecognizerStatus {set get}
    
    /// 测试结果
    var recognizeTxt: String {set get}
    
    func endSpeech()
 
    func startSpeech()
    
}

public enum LKSpeechRecognizerStatus:Int {
    //未开始
    case None
    ///未授权
    case noAuthorize
    ///识别中
    case recognizing
    ///识别结束
    case recognizeFinished
    ///识别关闭（被动关闭）
    case recognizeClose
    ///识别超时（超过预设静音时间(默认：3s)、主动结束）
    case recognizeMuteTimeout
    ///识别报错
    case recognizeError
}

/// 识别
public class SpeechObservation: ObservableObject {
    /// 识别状态
    @Published public var recognizeStatus: LKSpeechRecognizerStatus?
    
    /// 测试结果
    @Published public var recognizeTxt: String?
    
    public init() {
        
    }
}
