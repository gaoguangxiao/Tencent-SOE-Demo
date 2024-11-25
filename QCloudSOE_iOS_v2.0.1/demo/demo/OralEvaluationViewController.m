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
//#import "TAIOralEvaluationRetV2.h"
#import <MJExtension.h>

#import "demo-Swift.h"
#import "GXTaskDownload-Swift.h"
#import "ConfigFileViewController.h"

#import <GXAudioPlay-Swift.h>
#import "GGXSwiftExtension-Swift.h"
#import <RSBridgeAudioEvaluation-Swift.h>
#import <RSAdventureApi-Swift.h>
//旧版
#import <TAISDK/TAIOralEvaluation.h>
#import <QCloudRealTime/QCloudRealTimeRecognizer.h>
//音频格式转换
#import "GGXAudioConvertor.h"
#import "RSShowWaveView.h"
#import "TESTDATA.h" //读取文件

#import "MBProgressHUD.h"
#import "TAIDataSourceHandle.h" //对音频pcm、wav音频解析数据
@interface OralEvaluationViewController () <TAIOralListener, UITextFieldDelegate,TAIOralEvaluationDelegate,QCloudRealTimeRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *refText;

@property (weak, nonatomic) IBOutlet UISegmentedControl *evalModeSeg;//单词、句子
@property (weak, nonatomic) IBOutlet UISegmentedControl *engineSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *textModeSeg;//普通文本
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSeg;  //来源
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UISlider *coeffSlider;

@property (weak, nonatomic) IBOutlet UILabel *vadTxt;                    //静音时长标签
@property (weak, nonatomic) IBOutlet Slider *vadSlider;                  //静音音时长毫秒


@property (nonatomic, strong) RSShowWaveView *waveAudioView;             //音量视图
@property (weak, nonatomic) IBOutlet UIView *volumeView;
@property (weak, nonatomic) IBOutlet UILabel *volumeTxt;                 //音量标签
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgress;     //音量进度

@property (weak, nonatomic) IBOutlet UILabel *vadVolumeTxt;              //静音阈值标签
@property (weak, nonatomic) IBOutlet Slider *vadVolumeSlider;            //静音音量阈值
@property (weak, nonatomic) IBOutlet UISegmentedControl *sentenceInfoSeg;//输出断句结果中间显示
@property (weak, nonatomic) IBOutlet UITextField *keywordText;

@property (strong, nonatomic) TAIOralEvaluation *oralEvaluation;//智聆旧版
@property (nonatomic, strong) SOE *recordSOE;                   //获取智聆token相关
@property (nonatomic, strong) GXDownloadManager *downloader;    //下载音频
@property (nonatomic, strong) AudioFileTool *tool;              //文件播放器
@property (nonatomic, strong) TAIDataSourceHandle *dataSourceHandle; //定时解析音频数据

//@property (nonatomic, strong) TXSpeechTool *speechTools;//腾讯语言识别
@property (nonatomic, strong) QCloudRealTimeRecognizer *realTimeRecognizer;
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
//@property (nonatomic, strong) RSAudioEvaluationManagerV2 *audioEvaluationV2;
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
    //    _refText.text = @"how are you";
    _refText.text = @"ask";
    _refText.delegate = self;
    _keywordText.delegate = self;
    _vadSlider.needInt = YES;
    _vadVolumeSlider.needInt = YES;
    [_sentenceInfoSeg setSelectedSegmentIndex:1];
    
    [self.volumeView addSubview:self.waveAudioView];
    self.recordSOE = [SOE new];
    
    //    self.speechTools c= [TXSpeechTool new];
    //    self.speechTools.delegate = self;
    
    self.downloader = [GXDownloadManager new];
    self.tool = AudioFileTool.share;
    [self updateSource];
    
    self.dataSourceHandle = [TAIDataSourceHandle new];
    
    //    self.audioEvaluationV2 = [RSAudioEvaluationManagerV2 new];
    //    //保存待测试的网络数据
    //    NSString *re = [TESTDATA loadTestTxt:@"long_text_2024-10-18-16-20-39.txt"];
    //    [self.tool clearTxt];
    //    [self.tool saveTxtWithTxt:re];
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
                        //                        if (self.classVersion == 2) {
                        NSLog(@"audio path is: %@",path);
                        NSString *videoDestDateString = [mp3URL.lastPathComponent stringByDeletingPathExtension];
                        NSString *outPath = [NSString stringWithFormat:@"%@/%@.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], videoDestDateString];;
                        [GGXAudioConvertor convertM4AToWAV:path outPath:outPath success:^(NSString * _Nonnull outputPath) {
                            //                            NSLog(@"outputPath path is: %@",outputPath);
                            [self scoreWithByPath:path andwavPath:outputPath];
                        } failure:^(NSError * _Nonnull error) {
                            //                            NSLog(@"outputPath error is: %@",error);
                            [self scoreWithByPath:path andwavPath:nil];
                        }];
                        //                        } else {
                        //                            [self scoreWithByPath:path];
                        //                        }
                    }
                }];
            }
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
        self.audioPath = audiopath1;
        NSLog(@"audio path is: %@",self.audioPath);
        config.vadInterval = self->_vadSlider.value;
        config.vadVolume = self->_vadVolumeSlider.value;
    } else {
        
    }
    
    self->_ctl = nil;
    //    self->_source = nil;
    
    [self onStartButtonTouched];
    
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
    [_realTimeRecognizer stop];
    _realTimeRecognizer = nil;
}

//评测成功
- (void)onFinish {
    _running = false;
    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
    [_realTimeRecognizer stop];
    _realTimeRecognizer = nil;
    NSLog(@"SOE onFinish");
}

//评测中收到的服务端信息
- (void)onMessage:(nonnull NSString *)value {
    NSLog(@"SOE onMessage ----> %@", value);
    
    TAIOralEvaluationWordBase *eveluation = [TAIOralEvaluationWordBase objectValues:value];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[eveluation mj_JSONObject] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataStr =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _result = [NSString stringWithFormat:@"%@\n%@", _result, dataStr];
    
    [_resultText setText:_result];
    TAIOralEvaluationRetV2 *result = eveluation.result;
    if (result) {
        TAIOralEvaluationWordV2 *firstWord = result.Words.firstObject;
        //        if (firstWord) {
        //            _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.Word];
        //        }
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
    //    audioPoint.time = [[NSDate date] timeIntervalSince1970];
    [self.waveAudioView.pointArr addObject:audioPoint];
    //绘制音量
    [self.waveAudioView setNeedsDisplay];
}

- (void)onLog:(NSString *)value level:(int)level {
    NSLog(@"SOE logger ----> %@", value);
}



#pragma mark - 智聆旧版
- (void)onLocalRecord:(NSString *)audioPath andwavPath:(NSString *)wavPath{
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
    param.textMode = (TAIOralEvaluationTextMode)self.textModeSeg.selectedSegmentIndex;
    param.scoreCoeff = self.coeffSlider.value;
    param.fileType = TAIOralEvaluationFileType_Mp3;
    param.storageMode = TAIOralEvaluationStorageMode_Disable;
    
    param.refText = self.refText.text;
    
    TAIOralEvaluationData *data = [[TAIOralEvaluationData alloc] init];
    data.seqId = 1;
    data.bEnd = YES;
    data.audio = [NSData dataWithContentsOfFile:audioPath];
    //    __weak typeof(self) ws = self;
    [self.oralEvaluation oralEvaluation:param data:data callback:^(TAIError *error) {
        NSLog(@"onLocalRecord finish: %@",error);
        //        [ws setResponse:[NSString stringWithFormat:@"oralEvaluation:%@", error]];
    }];
    
    //
    [self.dataSourceHandle build:_source listener:self];
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
    
    [self onStartButtonTouched];
    
    
    [self.oralEvaluation setRecorderParam:recordParam];
    __weak typeof(self) ws = self;
    [self.oralEvaluation resetAvAudioSession:true];
    [self.oralEvaluation startRecordAndEvaluation:param callback:^(TAIError *error) {
        if(error.code == TAIErrCode_Succ){
            self->_running = true;
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
    
    if (result) {
        //        TAIOralEvaluationWord *firstWord = result.words.firstObject;
        //        if (firstWord) {
        //            _WordTxt.text = [NSString stringWithFormat:@"%@",firstWord.word];
        //        }
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
        //
        
        [self onResult:result.mj_JSONString];
    }
}

- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation  onEndOfSpeechInOralEvaluation:(BOOL)isSpeak {
    [self onRecord];
}

- (void)oralEvaluation:(TAIOralEvaluation *)oralEvaluation onVolumeChanged:(NSInteger)volume
{
    [self onVolume:(int)volume];
}

#pragma mark - 语言识别
- (void)onStartButtonTouched
{
    
    //    if (!_realTimeRecognizer) {
    //1.创建QCloudConfig实例
    //直接鉴权
    QCloudConfig *config = [[QCloudConfig alloc]initWithAppId:[PrivateInfo shareInstance].appId
                                                     secretId:[PrivateInfo shareInstance].secretId
                                                    secretKey:[PrivateInfo shareInstance].secretKey
                                                        token:[PrivateInfo shareInstance].token projectId:0];
    //        }else{
    //            config = [[QCloudConfig alloc] initWithAppId:kQDAppId secretId:kQDSecretId secretKey:kQDSecretKey token:kQDToken projectId:[kQDProjectId integerValue]];
    //        }
    
    /*使用临时密钥鉴权
     1.通过sts 获取到临时证书 （secretId secretKey  token） ,此步骤应在您的服务器端实现，见https://cloud.tencent.com/document/product/598/33416
     2.通过临时密钥调用接口
     */
    //    QCloudConfig *config = [[QCloudConfig alloc] initWithAppId:kQDAppId secretId:kQDSecretId secretId:@"填入临时SecretId" secretKey:@"填入临时SecretKey" token:@"对应的token" projectId:[kQDProjectId integerValue]];
    
    
    config.sliceTime = 40;                             //语音分片时长40ms
    config.enableDetectVolume = true; //是否检测音量
    config.endRecognizeWhenDetectSilence = _vadVolumeSlider.value > 0; //是否检测静音，静音阈值大于0检测
    //        config.endRecognizeWhenDetectSilenceAutoStop = YES;//是否检测到静音停止识别，默认YES
    config.silenceDetectDuration = _vadSlider.value/1000;
    config.requestTimeout = 10;
    //        16k_en：英文通用
    //        16k_zh：中文通用
    config.engineType = self.engineSeg.selectedSegmentIndex == 0 ? @"16k_en" : @"16k_zh"; //设置引擎，不设置默认16k_zh
    //        config.reinforceHotword = 1;
    config.noiseThreshold = 0.5;
    
    //是否压缩音频。默认压缩，压缩音频有助于优化弱网或网络不稳定时的识别速度及稳定性
    //SDK历史版本均默认压缩且不提供配置开关，如无特殊需求，建议使用默认值
    config.compression = YES;
    //        [config setApiParam:@"hotword_list" value:@"腾讯云|10,语音识别|5,ASR|11"];
    
    //是否保存录音文件到本地 默认关闭，仅限使用SDK内置录音器有效，
    //        config.shouldSaveAsFile = YES;
    //        config.saveFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"recordaudio.wav"];
    
    //2.创建QCloudRealTimeRecognizer实例
    
    //使用外部数据源传入语音数据，自定义data source需要实现QCloudAudioDataSource协议
    //        QCloudDemoAudioDataSource *dataSource = [[QCloudDemoAudioDataSource alloc] init];
    //        _realTimeRecognizer = [[QCloudRealTimeRecognizer alloc] initWithConfig:config dataSource:dataSource];
    
    //使用SDK内置录音器传入语音数据
    _realTimeRecognizer = [[QCloudRealTimeRecognizer alloc] initWithConfig:config];
    
//    [_realTimeRecognizer EnableDebugLog:YES];//是否打印日志
    
    //3.设置delegate
    _realTimeRecognizer.delegate = self;
    
    //    }
    
    //    [self startRecognizeIfNeed];
    //}
    //
    //- (void)startRecognizeIfNeed
    //{
    //
    //注意:使用内置录音器前需要先设置Category状态为可录音模式
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error) {
        NSLog(@"AVAudioSession setCategory error %@", error);
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    //    [self startWithRecorder];
    //    [self updateVolumeDB:0];
    //    if (_running) {
    //        [_realTimeRecognizer stop];
    //    }
    //    else {
    [_realTimeRecognizer start];
    //    }
}


#pragma mark - QCloudRealTimeRecognizerDelegate
- (void)realTimeRecognizerOnSegmentSuccessRecognize:(QCloudRealTimeRecognizer *)recognizer result:(QCloudRealTimeResult *)result
{
    _WordTxt.text = result.recognizedText;
    QCloudRealTimeResultResponse *currentResult = [result.resultList firstObject];
    NSLog(@"realTimeRecognizerOnSegmentSuccessRecognize:%@ index:%ld", currentResult.voiceTextStr, currentResult.index);
}

- (void)realTimeRecognizerOnSliceRecognize:(QCloudRealTimeRecognizer *)recognizer
                                    result:(QCloudRealTimeResult *)result
{
    if (0 == result.code) {
        _WordTxt.text = result.recognizedText;
        //        [PTDebugView addLog:result.recognizedText];
    }
    NSLog(@"realTimeRecognizerOnSliceRecognize result %@", [result debugDescription]);
    NSLog(@"result json text= %@", result.jsonText);
}

//一次识别成功回调
- (void)realTimeRecognizerDidFinish:(QCloudRealTimeRecognizer *)recorder result:(NSString *)result
{
    _WordTxt.text = result;
    NSLog(@"realTimeRecognizerDidFinish:%@", result);
}

//- (void)realTimeRecognizerDidStartRecord:(QCloudRealTimeRecognizer *)recorder error:(NSError *)error
//{
//    NSLog(@"realTimeRecognizerDidStartRecord error %@", error);
//    if (!error) {
//
//    }
//}

//- (void)realTimeRecognizerDidStopRecord:(QCloudRealTimeRecognizer *)recorder
//{
//    NSLog(@"realTimeRecognizerDidStopRecord");
//    _isRecording = NO;
//    [self stopAnimation];
//    [self updateButtonTitle];
//}

//- (void)realTimeRecognizerDidUpdateVolumeDB:(QCloudRealTimeRecognizer *)recognizer volume:(float)volume
//{
//    NSLog(@"realTimeRecognizerDidUpdateVolume volume:%lf", volume);
//    _volume = volume;
//    maxVolume = volume > maxVolume ? volume : maxVolume;
//    minVolume = volume < minVolume ? volume : minVolume;
//    [self updateVolumeDB:volume];
//}


//- (void)realTimeRecognizerOnFlowRecognizeStart:(QCloudRealTimeRecognizer *)recognizer voiceId:(NSString *)voiceId seq:(NSInteger)seq
//{
//    NSLog(@"realTimeRecognizerOnFlowRecognizeStart:%@ seq:%ld", voiceId, seq);
//}
/**
 * 检测到语音流结束识别
 * @param voiceId 本次识别对应的voiceId
 */
- (void)realTimeRecognizerOnFlowRecognizeEnd:(QCloudRealTimeRecognizer *)recognizer voiceId:(NSString *)voiceId seq:(NSInteger)seq
{
    NSLog(@"realTimeRecognizerOnFlowRecognizeEnd:%@ seq:%ld", voiceId, seq);
}




- (void)realTimeRecognizerDidError:(QCloudRealTimeRecognizer *)recognizer result:(QCloudRealTimeResult *)result;
{
    NSString* msg = nil;
    if(result.clientErrCode != QCloudRealTimeClientErrCode_Success){ //客户端返回的错误
        msg = [NSString stringWithFormat:@"realTimeRecognizerDidError:code=%@ errmsg=%@", @(result.clientErrCode),result.clientErrMessage];
        NSLog(@"%@", msg);
        //        _WordTxt.text = msg;
    }else{ //后端返回的错误
        msg = [NSString stringWithFormat:@"realTimeRecognizerDidError:code=%@ errmsg=%@", @(result.code),result.jsonText];
        NSLog(@"%@", msg);
        //        _WordTxt.text = msg;
    }
    //    [self.view makeToast:msg duration:1.3 position:CSToastPositionCenter];
}

//-(void)realTimeRecognizerOnSliceDetectTimeOut{
//    NSLog(@"realTimeRecognizeronSliceDetectTimeOut：触发了静音超时");
//当QCloudConfig.endRecognizeWhenDetectSilence 打开时，触发静音超时事件会回调此事件
//当QCloudConfig.endRecognizeWhenDetectSilenceAutoStop 打开时，回调此事件的同时会停止本次识别，此配置默认打开

//}
/**
 * 日志输出
 * @param log 日志
 */
//- (void)realTimeRecgnizerLogOutPutWithLog:(NSString *)log{

//    NSLog(@"log=====%@",log);
//}


#pragma mark - other
- (void)scoreWithByPath:(NSString *)path andwavPath:(NSString *)wavPath{
    self->_source = nil;
    if ([wavPath.pathExtension isEqualToString:@"wav"] || [wavPath.pathExtension isEqualToString:@"pcm"]) {
        self->_source = [[FileDataSource alloc] init:wavPath];
    } else {
        self->_source = [[AudioToolDataSource alloc] init:wavPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (self.classVersion == 2) {
            [self initTAIConfig:self-> _source];
        } else {
            [self onLocalRecord:path andwavPath:wavPath];
        }
    });
}

//获取到评分结果
- (void)onResult:(NSString *)result {
    
    //旧版停止
    [self.dataSourceHandle stop];
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

/**
 *  创建文件名
 */
- (NSString *)createFileNamePrefix {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss-sss"];//zzz
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
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
