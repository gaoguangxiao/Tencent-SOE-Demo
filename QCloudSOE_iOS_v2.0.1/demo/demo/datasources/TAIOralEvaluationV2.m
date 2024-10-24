//
//  TAIOralEvaluationV2.m
//  demo
//
//  Created by 高广校 on 2024/10/24.
//  启动、停止、解析数据逻辑

#import "TAIOralEvaluationV2.h"
#import <QCloudSOE/TAIOralConfig.h>
#import <QCloudSOE/TAIOralDataSource.h>
#import "TAIOralEvaluationRetV2.h"
#import <MJExtension.h>

#import "demo-Swift.h"

@interface TAIOralEvaluationV2()<TAIOralListener>
{
    id<TAIOralDataSource> _source;
    id<TAIOralController> _ctl;
    bool _running;
}

@property (nonatomic, strong) SOE *recordSOE;                   //获取智聆token相关

@end

@implementation TAIOralEvaluationV2

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recordSOE = [SOE new];
    }
    return self;
}

- (void)initTAIConfig:(id<TAIOralDataSource>)source andConfig:(TAIOralConfig *) config{
    
    [self.recordSOE startSOEWithCompletionHandler:^(NSInteger code) {
        
        config.appID = @"1321939176";
        config.token = [PrivateInfo shareInstance].token;
        config.secretID = [PrivateInfo shareInstance].secretId;
        config.secretKey = [PrivateInfo shareInstance].secretKey;
        
        self->_ctl = nil;
        
        self->_ctl =  [config build:source listener:self];
        
        self->_running = true;
    }];
}

#pragma mark - v2 delegate
- (void)onError:(nonnull NSError *)error {
    [_source stop];
    _running = false;
//    _result = [NSString stringWithFormat:@"%@\n%@", _result, error];
//    [_resultText setText:_result];
    NSLog(@"SOE onError ----> %@", error);
//    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测成功
- (void)onFinish {
    _running = false;
//    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测中收到的服务端信息
- (void)onMessage:(nonnull NSString *)value {
    NSLog(@"SOE onMessage ----> %@", value);
    
    TAIOralEvaluationWordBase *eveluation = [TAIOralEvaluationWordBase mj_objectWithKeyValues:value];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[eveluation mj_JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    _result = [NSString stringWithFormat:@"%@\n%@", _result, dataStr];
//    
//    [_resultText setText:_result];
//    TAIOralEvaluationRetV2 *result = eveluation.result;
//    if (result) {
//        TAIOralEvaluationWordV2 *firstWord = result.Words.firstObject;
//        if (firstWord) {
//            _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.Word];
//        }
//        _SuggestedScoreTxt.text = [NSString stringWithFormat:@"%.2f",result.SuggestedScore];
//        _PronCompletionTxt.text = [NSString stringWithFormat:@"%.2f",result.PronCompletion];
//        //        result.ti
//    }
}

//静音回调
- (void)onVad:(BOOL)value {
    if (!value) {
        [_ctl stop];
    }
}

//音量回调
- (void)onVolume:(int)value {
//    _volumeProgress.progress = value / 120.0;
//    _volumeTxt.text = [NSString stringWithFormat:@"音量：%d",value];
////    NSLog(@"%@：SOE onVolume ----> %d",[self createFileNamePrefix], value);
//    
//    MusicModel *audioPoint = [MusicModel new];
//    audioPoint.value = value;
//    [self.waveAudioView.pointArr addObject:audioPoint];
//    //绘制音量
//    [self.waveAudioView setNeedsDisplay];
}

- (void)onLog:(NSString *)value level:(int)level {
    NSLog(@"SOE logger ----> %@", value);
}

@end
