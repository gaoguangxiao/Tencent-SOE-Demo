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
#import "GGXSwiftExtension-Swift.h"
//旧版
#import <TAISDK/TAIOralEvaluation.h>

//音频格式转换
#import "GGXAudioConvertor.h"
#import "RSShowWaveView.h"
#import "TESTDATA.h" //读取文件

#import "MBProgressHUD.h"
#import "ParsingAudioHander.h"

@interface OralEvaluationViewController () <TAIOralListener, UITextFieldDelegate,TAIOralEvaluationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *refText;

@property (weak, nonatomic) IBOutlet UISegmentedControl *evalModeSeg;//单词、句子
@property (weak, nonatomic) IBOutlet UISegmentedControl *engineSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *textModeSeg;//普通文本
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSeg;  //来源
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UISlider *coeffSlider;

@property (weak, nonatomic) IBOutlet UILabel *vadTxt;                    //静音时常标签
@property (weak, nonatomic) IBOutlet Slider *vadSlider;


@property (nonatomic, strong) RSShowWaveView *waveAudioView;             //音量视图
@property (weak, nonatomic) IBOutlet UIView *volumeView;
@property (weak, nonatomic) IBOutlet UILabel *volumeTxt;                 //音量标签
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgress;     //音量进度

@property (weak, nonatomic) IBOutlet UILabel *vadVolumeTxt;              //静音阈值标签
@property (weak, nonatomic) IBOutlet Slider *vadVolumeSlider;            //静音阈值
@property (weak, nonatomic) IBOutlet UISegmentedControl *sentenceInfoSeg;//输出断句结果中间显示
@property (weak, nonatomic) IBOutlet UITextField *keywordText;

@property (strong, nonatomic) TAIOralEvaluation *oralEvaluation;//智聆旧版
@property (nonatomic, strong) SOE *recordSOE;                   //获取智聆token相关
@property (nonatomic, strong) GXDownloadManager *downloader;    //下载音频
@property (nonatomic, strong) AudioFileTool *tool;              //文件播放器

//音频评测面板
@property (weak, nonatomic) IBOutlet UILabel *WordTxt;//识别结果
@property (weak, nonatomic) IBOutlet UILabel *SuggestedScoreTxt;//建议评分
@property (weak, nonatomic) IBOutlet UILabel *PronCompletionTxt;//完整度
@property (weak, nonatomic) IBOutlet UILabel *PronAccuracyTxt;//精准度
@property (weak, nonatomic) IBOutlet UILabel *PronFluencyTxt;//流利度

//文件操作板
@property (weak, nonatomic) IBOutlet UIStackView *AudioSView;//网络文件粘贴视图
@property (weak, nonatomic) IBOutlet UILabel *AudioTxt;      //网络文件顺序标签

//录制音频
@property (nonatomic, copy) NSString *audioPath;

//将录制oc-该外swift工具
@property (nonatomic, strong) RSAudioEvaluationManagerV2 *audioEvaluationV2;
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
    
    [self.volumeView addSubview:self.waveAudioView];
    self.recordSOE = [SOE new];
    self.downloader = [GXDownloadManager new];
    self.tool = AudioFileTool.share;
    [self updateSource];
    
    self.audioEvaluationV2 = [RSAudioEvaluationManagerV2 new];
    //保存待测试的网络数据
    NSString *re = [TESTDATA loadTestTxt:@"long_text_2024-10-18-16-20-39.txt"];
    [self.tool clearTxt];
    [self.tool saveTxtWithTxt:re];
    self.AudioTxt.text = [NSString stringWithFormat:@"%ld/%ld：%@",(long)self->_tool.current  + 1,self->_tool.audios.count,[self->_tool cureentAudioURL]];
}

- (void)clearResult {
    [self.waveAudioView.pointArr removeAllObjects];
    [self.waveAudioView setNeedsDisplay];
    
    self.audioPath = nil;
    _result = @"";
    _WordTxt.text = @"";
    _SuggestedScoreTxt.text = @"";
    _PronCompletionTxt.text = @"";
    _PronAccuracyTxt.text = @"";
    _PronFluencyTxt.text = @"";
}

- (IBAction)onClick:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
//                    if([self.oralEvaluation isRecording]){
//                        __weak typeof(self) ws = self;
//                        [self.oralEvaluation stopRecordAndEvaluation:^(TAIError *error) {
//                            [ws setResponse:[NSString stringWithFormat:@"stopRecordAndEvaluation:%@", error]];
//                            [ws.actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
//                        }];
//                        return;
//                    }
                    
                    [self onRecord];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                //            } else if ([self ->_sourceSeg selectedSegmentIndex] == 1) {
                //                [self clearResult];
                //                // 文件源的pcm必须为单通道s16le格式
                //                NSString *path = [[NSBundle mainBundle] pathForResource:@"2024-10-22_10-20-49" ofType:@"pcm"];
                //                self.audioPath = path;
                //                //                NSString *path = [[NSBundle mainBundle] pathForResource:@"8c3c3533618547abb24176e73e3cc8f5" ofType:@"mp3"];
                //
                //                //                    NSString* path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.pcm"];
                //                //
                //                // 如果文件源不为pcm格式,可使用下面的方式//
                //                //                    NSString* path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.mp3"];
                //                if (self.classVersion == 2) {
                //                    if ([path.pathExtension isEqualToString:@"wav"] || [path.pathExtension isEqualToString:@"pcm"]) {
                //                        self->_source = [[FileDataSource alloc] init:path];
                //                    } else {
                //                        self->_source = [[AudioToolDataSource alloc] init:path];
                //                    }
                //                    [self initTAIConfig:self-> _source];
                //                } else {
                //                    [self onLocalRecord:path];
                //                }
                //
            } else {
                [self clearResult];
                // 文件源为网络音频 https://file.risekid.cn/record/problem/68055/493/2/8c3c3533618547abb24176e73e3cc8f5.mp3
                NSString *mp3URL = [self.tool cureentAudioURL];
                //下载音频
                [self.downloader downloadV2WithUrl:mp3URL path:@"problem" priority:0 clearOld:NO block:^(float progress, NSString * _Nullable path) {
                    
                    if (path) {
                        if (self.classVersion == 2) {
                            NSLog(@"audio path is: %@",path);
                            NSString *videoDestDateString = [mp3URL.lastPathComponent stringByDeletingPathExtension];
                            NSString *outPath = [NSString stringWithFormat:@"%@/%@.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], videoDestDateString];;
                            [GGXAudioConvertor convertM4AToWAV:path outPath:outPath success:^(NSString * _Nonnull outputPath) {
                                //                            NSLog(@"outputPath path is: %@",outputPath);
                                [self scoreWithByPath:outputPath];
                            } failure:^(NSError * _Nonnull error) {
                                //                            NSLog(@"outputPath error is: %@",error);
                                [self scoreWithByPath:path];
                            }];
                        } else {
                            [self scoreWithByPath:path];
                        }
                    }
                }];
            }
        });
    }];
}

- (void)scoreWithByPath:(NSString *)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (self.classVersion == 2) {
            if ([path.pathExtension isEqualToString:@"wav"] || [path.pathExtension isEqualToString:@"pcm"]) {
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

//静音音量阈值
- (IBAction)valChange:(UISlider *)sender {
//    NSLog(@"%.2f",sender.value);
    self.vadVolumeTxt.text = [NSString stringWithFormat:@"静音音量阈值：%.1f",sender.value];
}

- (IBAction)vadChange:(UISlider *)sender {
    self.vadTxt.text = [NSString stringWithFormat:@"静音时长（ms）：%.1f",sender.value];
}

- (void)updateSource {
    
    _AudioSView.hidden = _sourceSeg.selectedSegmentIndex == 0;
    self.AudioTxt.hidden = _sourceSeg.selectedSegmentIndex == 0;
    
}

//切换网络文件
- (IBAction)didLast:(UIButton *)sender {
    NSString *urlName = sender.tag == 0 ? [_tool lastAudioURL]:[_tool nextAudioURL];
    self.AudioTxt.text = [NSString stringWithFormat:@"%ld/%ld：%@",(long)_tool.current + 1,_tool.audios.count,urlName];
    //    NSLog(@"%@",self.AudioTxt.text);
}

//播放文件
- (IBAction)didPlayAudio:(id)sender {
    if ([self->_sourceSeg selectedSegmentIndex] == 0) {
        if (self.classVersion == 2) {
            [_tool playLocalWithPath:self.audioPath];
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

- (void)initTAIConfig:(id<TAIOralDataSource>)source {
    
    TAIOralConfig* config = [[TAIOralConfig alloc] init];
    config.appID = kQDAppId;
    config.token = [PrivateInfo shareInstance].token;
    config.secretID = [PrivateInfo shareInstance].secretId;
    config.secretKey = [PrivateInfo shareInstance].secretKey;
    //引擎
    [config setApiParam:kTAIServerEngineType value:self.engineSeg.selectedSegmentIndex == 0 ? @"16k_en" : @"16k_zh"];
    //文本模式
    [config setApiParam:kTAITextMode value:[@(self.textModeSeg.selectedSegmentIndex) stringValue]];
    //评测文本
    [config setApiParam:kTAIRefText value:self.refText.text];
    //关键词
    if (self->_keywordText.text.length) {
        [config setApiParam:kTAIKeyword value:self->_keywordText.text];
    }
    //评测模式
    [config setApiParam:kTAIEvalMode value:[@(self.evalModeSeg.selectedSegmentIndex) stringValue]];
    //苛刻度
    [config setApiParam:kTAIScoreCoeff value:[@(self.coeffSlider.value) stringValue]];
    NSString *sentenceinfoStr = [@(self.sentenceInfoSeg.selectedSegmentIndex) stringValue];
//    NSLog(@"传输模式：%@",sentenceinfoStr);
    //传输模式
    [config setApiParam:kTAISentenceInfoEnabled value:sentenceinfoStr];
    //网络超时时间
    config.connectTimeout = 3000;
    
    if ([source isKindOfClass:RecordDataSource.class]) {
        RecordDataSource *recordData = (RecordDataSource *)source;
        NSString *videoDestDateString = [self createFileNamePrefix];
        NSString *audiopath = [NSString stringWithFormat:@"%@/%@.pcm", NSTemporaryDirectory(),videoDestDateString];
        NSString *audiopath1 = [NSString stringWithFormat:@"%@/%@.wav", NSTemporaryDirectory(),videoDestDateString];
        config.audioFile = audiopath;
        
        //        config.audioFile = [NSString stringWithFormat:@"%@/%@.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], videoDestDateString];
        
        recordData.fileHandler.recordFilePath = audiopath1;
        self.audioPath = audiopath;
        NSLog(@"audio path is: %@",self.audioPath);
        config.vadInterval = self->_vadSlider.value;
        config.vadVolume = self->_vadVolumeSlider.value;
    } else {
        
    }
    
    self->_ctl = nil;
    //    self->_source = nil;
    
    self->_ctl =  [config build:source listener:self];
    
    self->_running = true;
    [self->_actionBtn setTitle:@"停止评测" forState:UIControlStateNormal];
        
    [self.waveAudioView startWave];
}

#pragma mark - v2 delegate
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
        _PronCompletionTxt.text = [NSString stringWithFormat:@"%.2f",result.PronCompletion];
        _PronAccuracyTxt.text   = [NSString stringWithFormat:@"%.2f",result.PronAccuracy];
        _PronFluencyTxt.text   = [NSString stringWithFormat:@"%.2f",result.PronFluency];
        if (result.PronCompletion >= 1.0 && result.PronAccuracy >= 60) {
            [self->_ctl stop];
        }
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
    _volumeTxt.text = [NSString stringWithFormat:@"音量：%d",value];
//    NSLog(@"%@：SOE onVolume ----> %d",[self createFileNamePrefix], value);
    
    MusicModel *audioPoint = [MusicModel new];
    audioPoint.value = value;
    [self.waveAudioView.pointArr addObject:audioPoint];
    //绘制音量
    [self.waveAudioView setNeedsDisplay];
}

- (void)onLog:(NSString *)value level:(int)level {
    NSLog(@"SOE logger ----> %@", value);
}

/**
 *  创建文件名
 */
- (NSString *)createFileNamePrefix {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss-sss"];//zzz
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
}

#pragma mark - 智聆旧版
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
    
//    ParsingAudioHander *audioHander =  [ParsingAudioHander new];
//    NSURL *url = [NSURL fileURLWithPath:mp3Path];
//    NSArray *datas = [audioHander calculateDBDecibelValuesFromBuffer:url];
    
//    [self.waveAudioView.pointArr addObjectsFromArray:datas];
}

- (void)onRecord {
    if([self.oralEvaluation isRecording]){
        __weak typeof(self) ws = self;
        [self.oralEvaluation stopRecordAndEvaluation:^(TAIError *error) {
            [ws setResponse:[NSString stringWithFormat:@"stopRecordAndEvaluation:%@", error]];
            [ws.actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
        }];
        return;
    }
    [self clearResult];
    TAIOralEvaluationParam *param = [[TAIOralEvaluationParam alloc] init];
    param.sessionId = [[NSUUID UUID] UUIDString];
    param.appId = [PrivateInfo shareInstance].appId;
    param.soeAppId = [PrivateInfo shareInstance].soeAppId;
    param.secretId = [PrivateInfo shareInstance].secretId;
    param.secretKey = [PrivateInfo shareInstance].secretKey;
    param.token = [PrivateInfo shareInstance].token;
    param.workMode = (TAIOralEvaluationWorkMode)self.sentenceInfoSeg.selectedSegmentIndex == 0? TAIOralEvaluationWorkMode_Once : TAIOralEvaluationWorkMode_Stream;
    param.evalMode = (TAIOralEvaluationEvalMode)self.evalModeSeg.selectedSegmentIndex;
    param.serverType = TAIOralEvaluationServerType_English;
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
    
    recordParam.vadInterval = self->_vadSlider.value;
    recordParam.db = self->_vadVolumeSlider.value;

    [self.oralEvaluation setRecorderParam:recordParam];
    __weak typeof(self) ws = self;
    [self.oralEvaluation resetAvAudioSession:true];
    [self.oralEvaluation startRecordAndEvaluation:param callback:^(TAIError *error) {
        if(error.code == TAIErrCode_Succ){
            [ws.actionBtn setTitle:@"停止评测" forState:UIControlStateNormal];
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
    
    if (result) {
        TAIOralEvaluationWord *firstWord = result.words.firstObject;
        if (firstWord) {
            _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.word];
        }
        _SuggestedScoreTxt.text = [NSString stringWithFormat:@"%.2f",result.suggestedScore];
        _PronCompletionTxt.text = [NSString stringWithFormat:@"%.2f",result.pronCompletion];
        _PronAccuracyTxt.text   = [NSString stringWithFormat:@"%.2f",result.pronAccuracy];
        _PronFluencyTxt.text   = [NSString stringWithFormat:@"%.2f",result.pronFluency];
        
        if (result.pronCompletion >= 1.0 && result.pronAccuracy >= 60) {
            [self.oralEvaluation stopRecordAndEvaluation:^(TAIError *error) {
                
            }];
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:[result mj_JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        _result = [NSString stringWithFormat:@"%@\n%@", _result, dataStr];
        [_resultText setText:_result];
        
        NSLog(@"oralEvaluation onMessage ----> %@", result.mj_JSONString);
    }
    
    if (data.bEnd) {
        [self onFinish];
    }
}

//- (void)onEndOfSpeechInOralEvaluation:(TAIOralEvaluation *)oralEvaluation
//{
//    [self onRecord];
//}

- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation  onEndOfSpeechInOralEvaluation:(BOOL)isSpeak {
    [self onRecord];
}

- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation onVolumeChanged:(NSInteger)volume
{
    [self onVolume:(int)volume];
}

- (void)setResponse:(NSString *)string
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    //    NSString *desc = [NSString stringWithCString:[string cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    //    NSString *text = _responseTextView.text;
//    NSString *text = [NSString stringWithFormat:@"%@ %@", [format stringFromDate:[NSDate date]], string];
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

//音量面板
- (RSShowWaveView *)waveAudioView {
    if (!_waveAudioView) {
        _waveAudioView = [[RSShowWaveView  alloc]initWithFrame:CGRectMake(0, 0, UIDevice.width, self.volumeView.height)];
    }
    return _waveAudioView;
}
@end
