//
//  RecordDataSource.m
//  demo
//
//  Created by tbolp on 2023/3/24.
//

#import "RecordDataSource.h"
#import "RecordFileHandler.h"
#import "Ring.h"

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);


@implementation RecordDataSource {
    AudioUnit _audioUnit;
    std::unique_ptr<Ring> _ring;
    NSObject* _lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSObject alloc] init];
        _fileHandler = [[RecordFileHandler alloc]init];
    }
    return self;
}

- (bool)empty {
    return false;
}

- (NSData *)read:(int)ms error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    int len = ms * 16 * 2;
    NSMutableData* ret = [NSMutableData dataWithCapacity:len];
    @synchronized (self) {
        auto info = self->_ring->data();
        for (auto& it : info) {
            if (it.len + ret.length > len) {
                [ret appendBytes:(const void*)it.data length:len - ret.length];
            }else {
                [ret appendBytes:(const void*)it.data length:it.len];
            }
        }
        self->_ring->pop((int)ret.length);
    }
    return ret;
}

- (NSError *)start {
    @synchronized (_lock) {
        if (_audioUnit) {
            AudioUnitParameterValue is_running;
            UInt32 size = sizeof(AudioUnitParameterValue);
            AudioUnitGetProperty(_audioUnit, kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, 0, &is_running, &size);
            if (is_running) {
                return nil;
            }
        }
        AVAudioSession* avsession = [AVAudioSession sharedInstance];
        NSError* error = nil;
        [avsession requestRecordPermission:^(BOOL granted) {
            
        }];
        if([avsession recordPermission] != AVAudioSessionRecordPermissionGranted) {
            return [NSError errorWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No Permission"}];
        }
        [avsession setCategory:AVAudioSessionCategoryRecord error:&error];
        if (error != nil) {
            return error;
        }
        [avsession setActive:YES error:&error];
        if (error != nil) {
            return error;
        }
        AudioComponentDescription desp;
        desp.componentType = kAudioUnitType_Output;
        desp.componentSubType = kAudioUnitSubType_RemoteIO;
        desp.componentManufacturer = kAudioUnitManufacturer_Apple;
        desp.componentFlags = 0;
        desp.componentFlagsMask = 0;
        
        AudioComponent input = AudioComponentFindNext(nil, &desp);
        if (input == nil) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioComponentFindNext Error"}];
        }
        
        OSStatus status = AudioComponentInstanceNew(input, &_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioComponentInstanceNew Error", @"Status": @(status)}];
        }
        
        UInt32 enableFlag = 1;
        status = AudioUnitSetProperty(_audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enableFlag, sizeof(enableFlag));
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"EnableIO AudioUnitSetProperty Error", @"Status": @(status)}];
        }
        AudioStreamBasicDescription audioFormat;
        audioFormat.mSampleRate = 16000.0;
        audioFormat.mFormatID = kAudioFormatLinearPCM;
        audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;//有符号整数和打包
        audioFormat.mFramesPerPacket = 1;
        audioFormat.mChannelsPerFrame = 1;
        audioFormat.mBitsPerChannel = 16;
        audioFormat.mBytesPerPacket = 2;
        audioFormat.mBytesPerFrame = 2;
        
        status = AudioUnitSetProperty(_audioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      1,
                                      &audioFormat,
                                      sizeof(audioFormat));
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Format AudioUnitSetProperty Error", @"Status": @(status)}];
        }
        
        AURenderCallbackStruct callbackStruct;
        callbackStruct.inputProc = recordingCallback;
        callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
        status = AudioUnitSetProperty(_audioUnit,
                                      kAudioOutputUnitProperty_SetInputCallback,
                                      kAudioUnitScope_Global,
                                      1,
                                      &callbackStruct,
                                      sizeof(callbackStruct));
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Callback AudioUnitSetProperty Error", @"Status": @(status)}];
        }
        
        status = AudioUnitInitialize(_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioUnitInitialize Error", @"Status": @(status)}];
        }
        decltype(_ring)(new Ring(16000*2*2)).swap(_ring);
        status = AudioOutputUnitStart(_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioOutputUnitStart Error", @"Status": @(status)}];
        }
        
        [_fileHandler startVoiceRecordByAudioQueue:nil
                                 isNeedMagicCookie:NO
                                         audioDesc:audioFormat];
        return nil;
    }
}

- (nullable NSError *)stop {
    @synchronized (_lock) {
        OSStatus status = AudioOutputUnitStop(_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioOutputUnitStop Error", @"Status": @(status)}];
        }
        status = AudioUnitUninitialize(_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioUnitUninitialize Error", @"Status": @(status)}];
        }
        status = AudioComponentInstanceDispose(_audioUnit);
        if (status != 0) {
            return [[NSError alloc] initWithDomain:@"Demo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"AudioComponentInstanceDispose Error", @"Status": @(status)}];
        }
        _audioUnit = nil;
        
        [_fileHandler stopVoiceRecordAudioConverter:nil needMagicCookie:NO];
        return nil;
    }
}

- (void)dealloc {
    [self stop];
}

int calculateDBFromInt16AudioBufferPCMDB(AudioBuffer audioBuffer) {
    // 计算 AudioBuffer 中数据的大小
    NSUInteger dataSize = audioBuffer.mDataByteSize;
    NSData *buffer = [NSData dataWithBytes:audioBuffer.mData length:dataSize];
    long long sum = 0; // 存储样本绝对值的总和
    short *pos = (short *)buffer.bytes; // 将 NSData 的字节转为 short 指针
//    SInt16 *curData = (SInt16 *)audioBuffer.mData; // 获取音频数据指针
    // 遍历所有样本
    for (int i = 0; i < buffer.length / 2; i++) {
        sum += abs(*pos); // 计算每个样本的绝对值并累加
        pos++; // 移动到下一个样本
    }

    // 计算 dB 值
    int db = (int)(sum * 600 / (buffer.length / 2 * 32767));
    if (db >= 120) {
        db = 120; // 限制最大值为 120
    }
    return db; // 返回计算出的 dB 值
}

float calculateDBFromInt16AudioBuffer(AudioBuffer audioBuffer) {
    SInt16 *curData = (SInt16 *)audioBuffer.mData; // 获取音频数据指针
    UInt32 frameCount = audioBuffer.mDataByteSize / sizeof(SInt16); // 计算样本数量
    if (frameCount == 0) {
        return -INFINITY; // 如果没有样本，返回负无穷大
    }
//    NSLog(@"frameCount is： %u",static_cast<unsigned int>(frameCount));
    float sum = 0.0;
    for (UInt32 i = 0; i < frameCount; i++) {
        SInt16 curDataValue = curData[i]; // 示例值
        float sample = curDataValue / 32768.0f; // 将 16 位样本转换为范围 [-1.0, 1.0]
//        NSLog(@"i is %d、curDataValueis: %.2hd： sample：%f",i,curDataValue,sample);
        float square = sample * sample;
//        NSLog(@"square is ：%f",square);
        sum = sum + square; // 计算平方和
//        NSLog(@"---sum： %f",sum);
    }
//    NSLog(@"all sum： %f",sum);
    float rms = sqrt(sum / frameCount);
//    NSLog(@"rms：%f",rms);
    // 如果 RMS 为零，返回 0 dB（表示无音量），RMS 值的范围是从 0 到 1，当转换为 dB 时，则可能会产生从负无穷大到 0 的值，而1的RMS对应0db，值越小分贝越大
    if (rms == 0) {
        return 0; // 处理无音信号
    }
    // 转换为分贝
    float dbValue = 20 * log10(rms);
    return dbValue;
}


static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    RecordDataSource* source = (__bridge RecordDataSource*)inRefCon;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mDataByteSize =inNumberFrames * sizeof(SInt16);// 设置数据大小
    bufferList.mBuffers[0].mNumberChannels = 1;
    bufferList.mBuffers[0].mData = malloc(inNumberFrames * sizeof(SInt16));// 为 mData 分配内存
    
    OSStatus status = AudioUnitRender(source->_audioUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      &bufferList);
    @synchronized (source) {
        source->_ring->push((char*)bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize);
        
        //填充数据
        [source.fileHandler writeFileWithInNumBytes:bufferList.mBuffers[0].mDataByteSize
                                       ioNumPackets:inNumberFrames
                                           inBuffer:bufferList.mBuffers[0].mData
                                       inPacketDesc:NULL];
        //计算分贝
//        float db = calculateDBFromInt16AudioBufferPCMDB(bufferList.mBuffers[0]);
//        NSLog(@"收到分贝：%.2f",db);
    }
    free(bufferList.mBuffers[0].mData);
    return status;
}

@end

