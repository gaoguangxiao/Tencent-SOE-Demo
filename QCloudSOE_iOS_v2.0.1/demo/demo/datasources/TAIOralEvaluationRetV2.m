//
//  TAIOralEvaluationRetV2.m
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

#import "TAIOralEvaluationRetV2.h"

@implementation Tone
@end

@implementation TAIOralEvaluationPhoneInfoV2
@end

@implementation TAIOralEvaluationWordBase
@end

@implementation TAIOralEvaluationRetV2

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"Words" : [TAIOralEvaluationWordV2 class],
    };
}
@end

@implementation TAIOralEvaluationWordV2
+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"PhoneInfos" : [TAIOralEvaluationPhoneInfoV2 class]};
}
@end
