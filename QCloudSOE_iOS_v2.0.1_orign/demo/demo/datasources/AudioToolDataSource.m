//
//  AudioToolDataSource.m
//  demo
//
//  Created by tbolp on 2024/5/29.
//

#import "AudioToolDataSource.h"
#import <AudioToolbox/AudioToolbox.h>
#include <vector>

@implementation AudioToolDataSource {
    NSString* _path;
    AudioFileID _audioFileID;
    AudioStreamBasicDescription _audioFormat;
    bool _end;
    SInt64 _start;
}

- (instancetype)init:(NSString *)path {
    self = [super init];
    if(self){
        _path = path;
        _end = false;
    }
    return self;
}

- (BOOL)empty { 
    return _end;
}

- (nonnull NSData *)read:(int)ms error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    Float64 sampleRate = _audioFormat.mSampleRate;
    UInt32 framesPerPacket = _audioFormat.mFramesPerPacket;
    Float32 millisecondsToRead = ms;
    UInt32 framesToRead = (UInt32)(sampleRate * millisecondsToRead / 1000.0);
    UInt32 packetsToRead = framesToRead / framesPerPacket;
    UInt32 numBytesToRead = packetsToRead * _audioFormat.mBytesPerPacket;
    std::vector<AudioStreamPacketDescription> packetsDesp(packetsToRead);
    if (_audioFormat.mBytesPerPacket == 0) {
        OSStatus status = AudioFileReadPacketData(_audioFileID, false, nullptr, &packetsDesp[0], _start, &packetsToRead, nullptr);
        if (status != noErr) {
            *error = [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioFileReadPacketData Get Packet Info Error", @"Status": @(status)}];
            return nil;
        }
        for (auto& it : packetsDesp) {
            numBytesToRead += it.mDataByteSize;
        }
    }
    if(numBytesToRead == 0) {
        _end = true;
        return nil;
    }
    std::vector<UInt8> audioData(numBytesToRead);
    OSStatus status = AudioFileReadPacketData(_audioFileID, false, &numBytesToRead, &packetsDesp[0], _start, &packetsToRead, &audioData[0]);
    if (status != noErr) {
        *error = [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioFileReadPacketData", @"Status": @(status)}];
        return nil;
    }
    _start += packetsToRead;
    NSData* ret = [[NSData alloc] initWithBytes:&audioData[0] length:numBytesToRead];
    return ret;
}

- (nullable NSError *)start {
    NSURL* url = [NSURL URLWithString:_path];
    OSStatus status = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &_audioFileID);
    if (status != noErr) {
        return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioFileOpenURL", @"Status": @(status)}];
    }
    UInt32 formatSize = sizeof(_audioFormat);
    status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyDataFormat, &formatSize, &_audioFormat);
    if (status != noErr) {
        return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioFileGetProperty", @"Status": @(status)}];
    }
    _end = false;
    _start = 0;
    return nil;
}

- (nullable NSError *)stop { 
    AudioFileClose(_audioFileID);
    return nil;
}

@end
