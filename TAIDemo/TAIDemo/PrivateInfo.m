//
//  PrivateInfo.m
//  TAIDemo
//
//  Created by kennethmiao on 2019/2/26.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import "PrivateInfo.h"

@implementation PrivateInfo

+ (instancetype)shareInstance
{
    static PrivateInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        自行传入appId, secretId, secretKey参数
        instance = [[PrivateInfo alloc] init];
        instance.appId = @"";
        instance.secretId = @"AKIDPa3AslAGFKDuG1vNnLNPy5HhPNXJDYE04B8RMAelNeNf4bwoviqovUm40QAJUHta";
        instance.secretKey = @"HQ5zfpGbt+P+SHYNV+QNJ3VAnw+Ionrmkxc5/0JJPKk=";
        instance.token = @"6HlHwiteUiBOlbSqnwPiB43nI0RmmAWa6bcce8c666df9ef8305c1877ca0b3f23ggRtQHcmZaXNJiIx6n7Sar5rrjZEVo_EoRBSiSKimIyffQPhRwLAuu7FWlsmGz3geS95VNYL0YBx72NujEvAmybrNDY52dk1GjHxX44To0C0zdYTrXlswNNHlwM7AnZCYCzLm57_stMZ-gHmIsm5K_AfXz2Kf3flQrp-OPcAdjF3F9I3yfpLjMvaR7hIh1yOscDkO5soPNV8EtSsOfPHeqJduLW6hvm63THaCNIi4yZOA4oF_LEhZumjpbDKvoukDqU0K29467J89OSszsgz316E3f_baExddddB3GWt2-3CAcO7VcCHFHkawlcfZbKiTEo2-X14UiDbTAkrmRDCVA";
        instance.soeAppId = @"";
        instance.hcmAppId = @"";
    });
    return instance;
}
@end
