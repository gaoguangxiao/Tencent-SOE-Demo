//
//  OralEvaluationViewController.m
//  TAIDemo
//
//  Created by kennethmiao on 2018/12/26.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "OralEvaluationViewController.h"
#import <QCloudSOE/TAIOralConfig.h>
#import <AVFoundation/AVFoundation.h>
#import "datasources/FileDataSource.h"
#import "datasources/RecordDataSource.h"
#import "datasources/AudioToolDataSource.h"
#import "UserInfo.h"
#import "PrivateInfo.h"
#import "Slider.h"
#import "TAIOralEvaluationRetV2.h"
#import <MJExtension.h>

#import "demo-Swift.h"
#import "GXTaskDownload-Swift.h"
#import "ConfigFileViewController.h"

#import <GXAudioPlay-Swift.h>

//旧版
#import <TAISDK/TAIOralEvaluation.h>
@interface OralEvaluationViewController () <TAIOralListener, UITextFieldDelegate,TAIOralEvaluationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *refText;

@property (weak, nonatomic) IBOutlet UISegmentedControl *evalModeSeg;//单词、句子
@property (weak, nonatomic) IBOutlet UISegmentedControl *engineSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *textModeSeg;//普通文本
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSeg;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UISlider *coeffSlider;
@property (weak, nonatomic) IBOutlet Slider *vadSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgress;
@property (weak, nonatomic) IBOutlet Slider *vadVolumeSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sentenceInfoSeg;//输出断句结果中间显示
@property (weak, nonatomic) IBOutlet UITextField *keywordText;


//旧版
@property (strong, nonatomic) TAIOralEvaluation *oralEvaluation;

@property (nonatomic, strong) SOE *recordSOE;

//下载音频至沙盒
@property (nonatomic, strong) GXDownloadManager *downloader;

//音频评测面板
@property (weak, nonatomic) IBOutlet UILabel *WordTxt;//识别结果
@property (weak, nonatomic) IBOutlet UILabel *SuggestedScoreTxt;//建议评分

//文件操作板
@property (weak, nonatomic) IBOutlet UIStackView *AudioSView;
@property (weak, nonatomic) IBOutlet UILabel *AudioTxt;
@property (nonatomic, strong) AudioFileTool *tool;

//录制音频
@property (nonatomic, copy) NSString *audioPath;
@end

@implementation OralEvaluationViewController {
    id<TAIOralDataSource> _source;
    id<TAIOralController> _ctl;
    NSString* _result;
    bool _running;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"录制版本:%ld",self.classVersion];
    _result = @"";
    _running = false;
    _refText.text = @"how are you";
    //    _refText.text = @"e";
    _refText.delegate = self;
    _keywordText.delegate = self;
    _vadSlider.needInt = YES;
    _vadVolumeSlider.needInt = YES;
    [_sentenceInfoSeg setSelectedSegmentIndex:1];
    
    self.recordSOE = [SOE new];
    self.downloader = [GXDownloadManager new];
    self.tool = AudioFileTool.share;
    [self updateSource];
}

- (void)clearResult {
    self.audioPath = nil;
    _result = @"";
    _WordTxt.text = @"";
    _SuggestedScoreTxt.text = @"";
}

- (void)initTAIConfig:(id<TAIOralDataSource>)source {
    
    TAIOralConfig* config = [[TAIOralConfig alloc] init];
    config.appID = kQDAppId;
    config.token = [PrivateInfo shareInstance].token;
    config.secretID = [PrivateInfo shareInstance].secretId;
    config.secretKey = [PrivateInfo shareInstance].secretKey;
    [config setApiParam:kTAIServerEngineType value:self.engineSeg.selectedSegmentIndex == 0 ? @"16k_en" : @"16k_zh"];
    [config setApiParam:kTAIEvalMode value:[@(self.evalModeSeg.selectedSegmentIndex) stringValue]];
    [config setApiParam:kTAIRefText value:self.refText.text];
    [config setApiParam:kTAIScoreCoeff value:[@(self.coeffSlider.value) stringValue]];
    [config setApiParam:kTAISentenceInfoEnabled value:[@(self.sentenceInfoSeg.selectedSegmentIndex) stringValue]];
    if (self->_keywordText.text.length) {
        [config setApiParam:kTAIKeyword value:self->_keywordText.text];
    }
    config.connectTimeout = 3000;
    
    if ([source isKindOfClass:RecordDataSource.class]) {
        NSString *videoDestDateString = [self createFileNamePrefix];
        config.audioFile =  [NSString stringWithFormat:@"%@/%@.pcm", NSTemporaryDirectory(),videoDestDateString];
//        config.audioFile = [NSString stringWithFormat:@"%@/%@.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], videoDestDateString];
        self.audioPath = config.audioFile;
        NSLog(@"audio path is: %@",config.audioFile);
        config.vadInterval = self->_vadSlider.value;
        config.vadVolume = self->_vadVolumeSlider.value;
    } else {
        
    }
    
    self->_ctl = nil;
    //    self->_source = nil;
    
    self->_ctl =  [config build:source listener:self];
    
    self->_running = true;
    [self->_actionBtn setTitle:@"停止评测" forState:UIControlStateNormal];
}

- (IBAction)onClick:(id)sender {
    
    [self.recordSOE startSOEWithCompletionHandler:^(NSInteger code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self->_sourceSeg selectedSegmentIndex] == 0) {
                if (self.classVersion == 2) {
                    if(self->_running) {
                        [self->_ctl stop];
                    } else {
                        [self clearResult];
                        self->_source = nil;
                        self->_source = [[RecordDataSource alloc] init];
                        [self initTAIConfig:self-> _source];
                    }
                } else {
                    if([self.oralEvaluation isRecording]){
                        __weak typeof(self) ws = self;
                        [self.oralEvaluation stopRecordAndEvaluation:^(TAIError *error) {
                            [ws setResponse:[NSString stringWithFormat:@"stopRecordAndEvaluation:%@", error]];
                            [ws.actionBtn setTitle:@"开始评分" forState:UIControlStateNormal];
                        }];
                        return;
                    }
                    [self onRecord];
                }
                
            } else if ([self ->_sourceSeg selectedSegmentIndex] == 1) {
                [self clearResult];
                // 文件源的pcm必须为单通道s16le格式
//                NSString *path = [[NSBundle mainBundle] pathForResource:@"2024-10-18_16-15-45" ofType:@"wav"];
                
                NSString *path = [[NSBundle mainBundle] pathForResource:@"8c3c3533618547abb24176e73e3cc8f5" ofType:@"mp3"];
                
                //                    NSString* path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.pcm"];
                //
                // 如果文件源不为pcm格式,可使用下面的方式//
                //                    NSString* path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.mp3"];
                if (self.classVersion == 2) {
                    if ([path.pathExtension isEqualToString:@"wav"] || [path.lastPathComponent isEqualToString:@"pcm"]) {
                        self->_source = [[FileDataSource alloc] init:path];
                    } else {
                        self->_source = [[AudioToolDataSource alloc] init:path];
                    }
                    [self initTAIConfig:self-> _source];
                } else {
                    [self onLocalRecord:path];
                }
                
            } else {
                [self clearResult];
                // 文件源为网络音频 https://file.risekid.cn/record/problem/68055/493/2/8c3c3533618547abb24176e73e3cc8f5.mp3
                //                    NSString *mp3URL = @"https://file.risekid.cn/record/problem/68055/493/2/8c3c3533618547abb24176e73e3cc8f5.mp3";
                
                //下载音频
                [self.downloader downloadV2WithUrl:[self->_tool cureentAudioURL] path:@"problem" priority:0 block:^(float progress, NSString * _Nullable path) {
                    if (path) {
                        NSLog(@"audio path is: %@",path);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.classVersion == 2) {
                                if ([path.pathExtension isEqualToString:@"wav"] || [path.lastPathComponent isEqualToString:@"pcm"]) {
                                    self->_source = [[FileDataSource alloc] init:path];
                                } else {
                                    self->_source = [[AudioToolDataSource alloc] init:path];
                                }
                                [self initTAIConfig:self-> _source];
                            } else {
                                [self onLocalRecord:path];
                            }
                        });
                    }
                }];
            }
            
            //            }
        });
    }];
}

- (IBAction)PauseAudioFile:(id)sender {
    
    ConfigFileViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConfigFileViewController"];
    controller.isSaveAudios = ^{
        NSLog(@"%@",[AudioFileTool.share cureentAudioURL]);
        self.AudioTxt.text = [NSString stringWithFormat:@"%ld/%ld：%@",(long)self->_tool.current  + 1,self->_tool.audios.count,[self->_tool cureentAudioURL]];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

//切换
- (IBAction)SegChangeSource:(UISegmentedControl *)sender {
    [self updateSource];
}

- (void)updateSource {
    
    _AudioSView.hidden = _sourceSeg.selectedSegmentIndex == 0;
    
    if (_sourceSeg.selectedSegmentIndex == 0) {
        //        _AudioSView.hidden = YES;
    } else {
        
    }
}

- (IBAction)didLast:(UIButton *)sender {
    
    NSString *urlName = sender.tag == 0 ? [_tool lastAudioURL]:[_tool nextAudioURL];
    self.AudioTxt.text = [NSString stringWithFormat:@"%ld/%ld：%@",(long)_tool.current + 1,_tool.audios.count,urlName];
    
//    NSLog(@"%@",self.AudioTxt.text);
}

- (IBAction)didPlayAudio:(id)sender {
    
    if ([self->_sourceSeg selectedSegmentIndex] == 0) {
//        if (self.audioPath) {
//            [_tool playLocalWithPath:self.audioPath];
//        } else {
//            //
//        }
        if (self.classVersion == 2) {
            [_tool playAudioWithAVWithPath:self.audioPath];
        } else {
            [_tool playAudioWithAVWithPath:self.audioPath];
        }
    } else {
        [_tool playAudio];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - ui delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_refText resignFirstResponder];
    [_keywordText resignFirstResponder];
    return YES;
}

- (void)onError:(nonnull NSError *)error {
    [_source stop];
    _running = false;
    _result = [NSString stringWithFormat:@"%@\n%@", _result, error];
    [_resultText setText:_result];
    NSLog(@"SOE onError ----> %@", _result);
    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测成功
- (void)onFinish {
    _running = false;
    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测中收到的服务端信息
- (void)onMessage:(nonnull NSString *)value {
    NSLog(@"SOE onMessage ----> %@", value);
    
    TAIOralEvaluationWordBase *eveluation = [TAIOralEvaluationWordBase mj_objectWithKeyValues:value];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[eveluation mj_JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _result = [NSString stringWithFormat:@"%@\n%@", _result, dataStr];
    
    [_resultText setText:_result];
    TAIOralEvaluationRetV2 *result = eveluation.result;
    if (result) {
        TAIOralEvaluationWordV2 *firstWord = result.Words.firstObject;
        if (firstWord) {
            _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.Word];
        }
        _SuggestedScoreTxt.text = [NSString stringWithFormat:@"%.2f",result.SuggestedScore];
    }
}

//静音回调
- (void)onVad:(BOOL)value {
    if (!value) {
        [_ctl stop];
    }
}

//音量回调
- (void)onVolume:(int)value {
    _volumeProgress.progress = value / 120.0;
}

- (void)onLog:(NSString *)value level:(int)level {
    NSLog(@"SOE logger ----> %@", value);
}

/**
 *  创建文件名
 */
- (NSString *)createFileNamePrefix {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];//zzz
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
}

///---------------旧版

- (void)onLocalRecord:(NSString *)mp3Path {
    TAIOralEvaluationParam *param = [[TAIOralEvaluationParam alloc] init];
    param.sessionId = [[NSUUID UUID] UUIDString];
    //    param.appId = [PrivateInfo shareInstance].appId;
    //    param.soeAppId = [PrivateInfo shareInstance].soeAppId;
    param.token = [PrivateInfo shareInstance].token;
    param.secretId = [PrivateInfo shareInstance].secretId;
    param.secretKey = [PrivateInfo shareInstance].secretKey;
    param.workMode = TAIOralEvaluationWorkMode_Once;
    param.evalMode = (TAIOralEvaluationEvalMode)self.evalModeSeg.selectedSegmentIndex;
    param.serverType = TAIOralEvaluationServerType_English;
    param.scoreCoeff = self.coeffSlider.value;
    param.fileType = TAIOralEvaluationFileType_Mp3;
    param.storageMode = TAIOralEvaluationStorageMode_Disable;
    param.textMode = (TAIOralEvaluationTextMode)self.textModeSeg.selectedSegmentIndex;
    param.refText = self.refText.text;
    
    TAIOralEvaluationData *data = [[TAIOralEvaluationData alloc] init];
    data.seqId = 1;
    data.bEnd = YES;
    data.audio = [NSData dataWithContentsOfFile:mp3Path];
    __weak typeof(self) ws = self;
    [self.oralEvaluation oralEvaluation:param data:data callback:^(TAIError *error) {
        //        [ws setResponse:[NSString stringWithFormat:@"oralEvaluation:%@", error]];
    }];
}

- (void)onRecord {
    if([self.oralEvaluation isRecording]){
        __weak typeof(self) ws = self;
        [self.oralEvaluation stopRecordAndEvaluation:^(TAIError *error) {
            [ws setResponse:[NSString stringWithFormat:@"stopRecordAndEvaluation:%@", error]];
            [ws.actionBtn setTitle:@"开始评分" forState:UIControlStateNormal];
        }];
        return;
    }
    
    TAIOralEvaluationParam *param = [[TAIOralEvaluationParam alloc] init];
    param.sessionId = [[NSUUID UUID] UUIDString];
    param.appId = [PrivateInfo shareInstance].appId;
    param.soeAppId = [PrivateInfo shareInstance].soeAppId;
    param.secretId = [PrivateInfo shareInstance].secretId;
    param.secretKey = [PrivateInfo shareInstance].secretKey;
    param.token = [PrivateInfo shareInstance].token;
    //    param.workMode = (TAIOralEvaluationWorkMode)self.w.selectedSegmentIndex;
    param.evalMode = (TAIOralEvaluationEvalMode)self.evalModeSeg.selectedSegmentIndex;
    param.serverType = (TAIOralEvaluationServerType)self.sourceSeg.selectedSegmentIndex;
    param.hostType = TAIOralEvaluationHostType_Common;//(TAIOralEvaluationHostType)self.sourceSeg.selectedSegmentIndex;
    param.scoreCoeff = self.coeffSlider.value;
    param.fileType = TAIOralEvaluationFileType_Mp3;
    param.storageMode = TAIOralEvaluationStorageMode_Enable;
    param.textMode = (TAIOralEvaluationTextMode)self.textModeSeg.selectedSegmentIndex;
    param.refText = self.refText.text;
    
    param.audioPath = [NSString stringWithFormat:@"%@/%@.mp3", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], param.sessionId];
    self.audioPath = param.audioPath;
    if(param.workMode == TAIOralEvaluationWorkMode_Stream){
        param.timeout = 5;
        param.retryTimes = 5;
    }
    else{
        param.timeout = 30;
        param.retryTimes = 0;
    }

    TAIRecorderParam *recordParam = [[TAIRecorderParam alloc] init];
    recordParam.fragEnable = (param.workMode == TAIOralEvaluationWorkMode_Stream ? YES: NO);
    recordParam.fragSize = 1.0 * 1024;
    recordParam.vadEnable = YES;
    //    recordParam.vadInterval = [_vadTextField.text intValue];
    [self.oralEvaluation setRecorderParam:recordParam];
    __weak typeof(self) ws = self;
    [self.oralEvaluation resetAvAudioSession:true];
    [self.oralEvaluation startRecordAndEvaluation:param callback:^(TAIError *error) {
        if(error.code == TAIErrCode_Succ){
            [ws.actionBtn setTitle:@"停止录制" forState:UIControlStateNormal];
        }
        [ws setResponse:[NSString stringWithFormat:@"startRecordAndEvaluation:%@", error]];
    }];
}

#pragma mark - oral evaluation delegate
- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation onEvaluateData:(TAIOralEvaluationData *)data result:(TAIOralEvaluationRet *)result error:(TAIError *)error
{
    if(error.code != TAIErrCode_Succ){
        //        [_recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    }
//    NSString *log = [NSString stringWithFormat:@"oralEvaluation:seq:%ld, end:%ld, error:%@, ret:%@", (long)data.seqId, (long)data.bEnd, error, result];
//    NSLog(@"oralEvaluation onMessage ----> %@", log);
//    _result = [NSString stringWithFormat:@"%@\n%@", _result, log];
//    [_resultText setText:_result];
    
    if (data.bEnd) {
//        TAIOralEvaluationRetV2 *result = eveluation.result;
        if (result) {
            TAIOralEvaluationWord *firstWord = result.words.firstObject;
            if (firstWord) {
                _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.word];
            }
            _SuggestedScoreTxt.text = [NSString stringWithFormat:@"%.2f",result.suggestedScore];
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:[result mj_JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        _result = [NSString stringWithFormat:@"%@\n%@", _result, dataStr];
        [_resultText setText:_result];
        
        NSLog(@"oralEvaluation onMessage ----> %@", result.mj_JSONString);
    }
}

- (void)onEndOfSpeechInOralEvaluation:(TAIOralEvaluation *)oralEvaluation
{
    [self setResponse:@"onEndOfSpeech"];
    //    [self onRecord:nil];
}

- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation onVolumeChanged:(NSInteger)volume
{
    //    self.progressView.progress = volume / 120.0;
}

- (void)setResponse:(NSString *)string
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //    NSString *desc = [NSString stringWithCString:[string cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    //    NSString *text = _responseTextView.text;
    NSString *text = [NSString stringWithFormat:@"%@ %@", [format stringFromDate:[NSDate date]], string];
    //    _responseTextView.text = text;
    //    NSLog(@"SOE onMessage ----> %@", text);
}

- (TAIOralEvaluation *)oralEvaluation
{
    if(!_oralEvaluation){
        _oralEvaluation = [[TAIOralEvaluation alloc] init];
        _oralEvaluation.delegate = self;
    }
    return _oralEvaluation;
}
@end
