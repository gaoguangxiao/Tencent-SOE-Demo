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
        instance.secretId = @"AKIDUFa44NzNdjW3zMM2YdbcHlQXFVeT0f0tkJJMeZCmrp06CRn1FIEhpsMlWpWFuGkg";
        instance.secretKey = @"m0YdedZVkPXm42sqlm7tL4Ad2nwaoZ47vhHptUD44vY=";
        instance.token = @"6HlHwiteUiBOlbSqnwPiB43nI0RmmAWa868ef7e7810f70fe56654b5f85336043ggRtQHcmZaXNJiIx6n7SamxCmWN0w7gL0nANb5GINFO25lwoHFOWgsKAeBrKu07J4GQDgQ3vQNXb79zr8R7QbAmq7frJ2Qii6qeMnaJhrYnCg8PXU7OKnpEFePGPSqcrCdnIs7Z0Ex0rGOeEq4DqtwJoRvwO5Eo3CJFe3HpuFVFD-reI2mYSQo7catYer1gqEnuDNlfxsUmp1adNJkw2xANPV3Rv-olNxqxr3G53Cu0shq70wb-jUBfnIhQ-y6fE_69nBi6Y8zbqtwWpIrhtcTVQ9xcxzOmUb4LHJ2Pn522p8vS9jHGR0eIqqiWAQV3GJHq1SZgDdCk2nWgvfZ3Wjw";
        instance.soeAppId = @"";
        instance.hcmAppId = @"";
    });
    return instance;
}
@end
