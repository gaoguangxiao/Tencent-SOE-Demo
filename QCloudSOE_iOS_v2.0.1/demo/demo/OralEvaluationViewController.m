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

#import "demo-Swift.h"

@interface OralEvaluationViewController () <TAIOralListener, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *refText;

@property (weak, nonatomic) IBOutlet UISegmentedControl *evalModeSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *engineSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *textModeSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sourceSeg;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UISlider *coeffSlider;
@property (weak, nonatomic) IBOutlet Slider *vadSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgress;
@property (weak, nonatomic) IBOutlet Slider *vadVolumeSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sentenceInfoSeg;
@property (weak, nonatomic) IBOutlet UITextField *keywordText;

@property (nonatomic, strong) SOE *recordSOE;
@end

@implementation OralEvaluationViewController {
    id<TAIOralDataSource> _source;
    id<TAIOralController> _ctl;
    NSString* _result;
    bool _running;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _result = @"";
    _running = false;
    _refText.delegate = self;
    _keywordText.delegate = self;
    _vadSlider.needInt = YES;
    _vadVolumeSlider.needInt = YES;
    [_sentenceInfoSeg setSelectedSegmentIndex:1];
    
    self.recordSOE = [SOE new];
}

- (IBAction)onClick:(id)sender {
    
    [self.recordSOE startSOEWithCompletionHandler:^(NSInteger code) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_running) {
                [self->_ctl stop];
            }else{
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
                NSString *videoDestDateString = [self createFileNamePrefix];
//                config.audioFile =  [NSString stringWithFormat:@"%@/%@.pcm", NSTemporaryDirectory(),videoDestDateString];
                config.audioFile = [NSString stringWithFormat:@"%@/%@.wav", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], videoDestDateString];
                config.vadInterval = self->_vadSlider.value;
                config.vadVolume = self->_vadVolumeSlider.value;
                config.connectTimeout = 3000;
                self->_ctl = nil;
                self->_source = nil;
                if ([self->_sourceSeg selectedSegmentIndex] == 0) {
                    self->_source = [[RecordDataSource alloc] init];
                } else {
                    // 文件源的pcm必须为单通道s16le格式
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"2024-10-16_10-00-27" ofType:@"wav"];
//                    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.wav"];
                    self->_source = [[FileDataSource alloc] init:path];
                    // 如果文件源不为pcm格式,可使用下面的方式
        //             [config setApiParam:kTAIVoiceFormat value:@"2"];
//
//                    NSString*wavPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]bundlePath], @"how_are_you.mp3"];
//                    self->_source = [[AudioToolDataSource alloc] init:wavPath];
                }
                self->_ctl =  [config build:self->_source listener:self];
                self->_result = @"";
                self->_running = true;
                [self->_actionBtn setTitle:@"停止评测" forState:UIControlStateNormal];
            }
        });
       
        
    }];
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
    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测成功
- (void)onFinish {
    _running = false;
    [_actionBtn setTitle:@"开始评测" forState:UIControlStateNormal];
}

//评测中收到的服务端信息
- (void)onMessage:(nonnull NSString *)value {
    _result = [NSString stringWithFormat:@"%@\n%@", _result, value];
    [_resultText setText:_result];
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
@end
