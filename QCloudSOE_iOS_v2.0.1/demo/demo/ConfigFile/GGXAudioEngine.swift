//
//  GGXAudioEngine.swift
//  demo
//
//  Created by 高广校 on 2024/10/22.
//

import Foundation
import AVFoundation

public class GGXAudioEngine: NSObject {
    // 创建AVAudioEngine和AVAudioPlayerNode
    let audioEngine = AVAudioEngine()
    
    let audioPlayerNode = AVAudioPlayerNode()
    
    let format = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 1)!
    
    override init() {
        audioEngine.attach(audioPlayerNode)
        // 连接音频节点
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: format)
        // 启动音频引擎
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    public func stopEngine() {
        audioEngine.stop()
    }
    
    public func playpcm(fileURL fileUrl: URL) throws {
        // 播放PCM数据
        if let pcmBuffer = setAudioPCMBuffer(fileUrl: fileUrl) {
            // 播放PCM数据
            audioPlayerNode.scheduleBuffer(pcmBuffer, at: nil, options: .interrupts, completionHandler: nil)
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            audioPlayerNode.play()
            print("play is: \(fileUrl)")
        }
    }
}

extension GGXAudioEngine {
    //    ---------- 填充pcmData到AVAudioPCMBuffer
    private func readPCMFile(atPath fileURL: URL) -> Data? {
        do {
            // 使用FileHandle打开文件
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            // 读取文件数据
            let fileData = fileHandle.readDataToEndOfFile()
            // 关闭文件
            fileHandle.closeFile()
            return fileData
        } catch {
            print("Error reading PCM file: \(error)")
            return nil
        }
    }
    
    private func setAudioPCMBuffer(fileUrl: URL) -> AVAudioPCMBuffer? {
        guard let pcmData = readPCMFile(atPath: fileUrl) else { return nil }
        
        let bufferSize = AVAudioFrameCount(pcmData.count) / format.channelCount
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                               frameCapacity: bufferSize) else { return nil }
        pcmBuffer.frameLength = bufferSize
        
        guard let channelData = pcmBuffer.floatChannelData?.pointee else { return nil }
        // 将Data中的PCM数据复制到缓冲区
        let sampleCount = pcmData.count / MemoryLayout<Int16>.size
        let samples = UnsafeMutablePointer<Float>.allocate(capacity: sampleCount)
        // 这里假设PCM数据是16位整型格式，你需要根据实际情况调整
        pcmData.withUnsafeBytes { (rawBufferPointer) in
            let pointer = rawBufferPointer.bindMemory(to: Int16.self)
            for i in 0..<sampleCount {
                // 将16位样本转换为Float，范围从-1.0到1.0
                samples[i] = Float(pointer[i]) / Float(Int16.max)
            }
        }
        memcpy(channelData, samples, Int(bufferSize) * MemoryLayout<Float>.size)
        samples.deallocate()
        return pcmBuffer
    }
    
}
