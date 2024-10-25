//
//  FileDataSourceHandle.m
//  demo
//
//  Created by 高广校 on 2024/10/25.
//

#import "TAIDataSourceHandle.h"

@interface TAIDataSourceHandle()
{
    id<TAIOralDataSource> _source;
    
    id<TAIOralListener> _listener;
}
@property (nonatomic, strong) NSTimer *readAudioTimer;  //定时读取音频数据

@end

@implementation TAIDataSourceHandle

- (void)build:(id<TAIOralDataSource>)source listener:(id<TAIOralListener>)listener {
    
    _source = source;
    
    _listener = listener;
    
    NSError *error = [_source start];
    
    [self addReadAudioTimer];
}

- (void)stop {
    //
    [_source stop];
    
    [self removeReadAudioTimer];
}

- (void)onTimerVolume {
    NSError *error;
    
    NSData *data = [_source read:40 error:&error];
    
    int db = [self getPCMDB:data];

    [_listener onVolume:db];
}

-(int)getPCMDB:(NSData* )buffer
{
    //https://blog.csdn.net/balijinyi/article/details/80284520
    long long sum = 0;
    short *pos = (short *)buffer.bytes;
    for (int i = 0; i < buffer.length /2; i++){
        sum += abs(*pos);
        pos++;
    }
    int db = (int)(sum * 600 / (buffer.length / 2 * 32767));
    if(db >= 120){
        db = 120;
    }
    return db;
}

- (void)removeReadAudioTimer {
    [_readAudioTimer invalidate];
    _readAudioTimer = nil;
}

- (void)addReadAudioTimer{
    if (!_readAudioTimer) {
        _readAudioTimer = [NSTimer scheduledTimerWithTimeInterval:.025f target:self selector:@selector(onTimerVolume) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_readAudioTimer forMode:NSRunLoopCommonModes];
    }
}
@end
