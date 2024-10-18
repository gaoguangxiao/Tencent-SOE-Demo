//
//  TAIOralEvaluationRetV2.h
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tone : NSObject

@property (nonatomic, assign) BOOL Valid;
@end

@interface TAIOralEvaluationPhoneInfoV2 : NSObject
//当前音节语音起始时间点，单位为ms
@property (nonatomic, assign) int MemBeginTime;
//当前音节语音终止时间点，单位为ms
@property (nonatomic, assign) int MemEndTime;
//音节发音准确度，取值范围[-1, 100]，当取-1时指完全不匹配
@property (nonatomic, assign) float PronAccuracy;
//当前音节是否检测为重音
@property (nonatomic, assign) BOOL DetectedStress;
//当前音节是否应为重音
@property (nonatomic, assign) BOOL Stress;
//当前音节
@property (nonatomic, strong) NSString *Phone;
//参考音素，在单词诊断模式下，代表标准音素
@property (nonatomic, strong) NSString *ReferencePhone;
//音素对应的字母
@property (nonatomic, strong) NSString *ReferenceLetter;
//当前词与输入语句的匹配情况，0：匹配单词、1：新增单词、2：缺少单词、3：错读的词、4：未录入单词。
@property (nonatomic, assign) int MatchTag;
@end

@interface TAIOralEvaluationWordV2 : NSObject

//当前单词语音起始时间点，单位为ms
@property (nonatomic, assign) int MemBeginTime;
//当前单词语音终止时间点，单位为ms
@property (nonatomic, assign) int MemEndTime;
//单词发音准确度，取值范围[-1, 100]，当取-1时指完全不匹配
@property (nonatomic, assign) float PronAccuracy;
//单词发音流利度，取值范围[0, 1]
@property (nonatomic, assign) float PronFluency;
//当前词
@property (nonatomic, strong) NSString *Word;
//参考词
@property (nonatomic, strong) NSString *ReferenceWord;
//当前词与输入语句的匹配情况，0：匹配单词、1：新增单词、2：缺少单词、3：错读的词、4：未录入单词。
@property (nonatomic, assign) int MatchTag;

@property (nonatomic, assign) int KeywordTag;
//音节评估详情
@property (nonatomic, strong) NSArray<TAIOralEvaluationPhoneInfoV2 *> *PhoneInfos;

@property (nonatomic, strong) Tone *Tone;
@end

@interface TAIOralEvaluationRetV2 : NSObject

//建议评分，取值范围[0,100]
//评分方式为建议评分 = 准确度（PronAccuracyfloat）× 完整度（PronCompletionfloat）×（2 - 完整度（PronCompletionfloat））
//如若评分策略不符合请参考Words数组中的详细分数自定义评分逻辑。
@property (nonatomic, assign) float SuggestedScore;

//单词发音准确度，取值范围[-1, 100]，当取-1时指完全不匹配
@property (nonatomic, assign) float PronAccuracy;
//单词发音流利度，取值范围[0, 1]
@property (nonatomic, assign) float PronFluency;
//发音完整度，取值范围[0, 1]，当为词模式时，取值无意义
@property (nonatomic, assign) float PronCompletion;

//详细发音评估结果
@property (nonatomic, strong) NSArray<TAIOralEvaluationWordV2 *> *Words;

//句子序号，在段落、自由说模式下有效，表示断句序号，最后的综合结果的为-1.
@property (nonatomic, assign) NSInteger sentenceID;

//单词发音流利度，取值范围[0, 1]
@property (nonatomic, assign) NSInteger RefTextId;

/**
* 主题词命中标志，0表示没命中，1表示命中
* 注意：此字段可能返回 null，表示取不到有效值。
*/
@property (nonatomic, strong) NSArray<NSNumber *> *KeyWordHits;


/**
* 负向主题词命中标志，0表示没命中，1表示命中
* 注意：此字段可能返回 null，表示取不到有效值。
*/
@property (nonatomic, strong) NSArray<NSNumber *> *UnKeyWordHits;
@end

@interface TAIOralEvaluationWordBase : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, copy)   NSString *voice_id;
@property (nonatomic, strong) TAIOralEvaluationRetV2 *result;

@end
NS_ASSUME_NONNULL_END
