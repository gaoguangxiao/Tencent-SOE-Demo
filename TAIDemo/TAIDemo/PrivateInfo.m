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
        instance.secretId = @"AKID2ItOLRb1LXi_bZceewvVlSzkPvH7_C8sCAStZtQo6NJdCk-PjCWPm-IOnCZV1ng2";
        instance.secretKey = @"3t6WZCVYdWIgzN1/SJVvgDXQYhVWWFItOSXoiN4cu3M=";
        instance.token = @"dBEKOHhAUhyAhFhz2HEO1C3xztuUOvIa8550232a5b1918feb55f87f3cd8da149C2hSvGCRDO01pZHLDGHQjcPss0y0ol6pIAaH19sVxGJ0CS_tF6Fn7eiIv-lAd8bMCpzZlKyLZrBe-BHfCAv9ursH9OdmTOc8TTszC9ur7N2Z9tESd9mYjCV362KkmIK2ARztBZYPPOZr3HUNvV6EwFw6s5EGGFiaJ2nkQDcpd_1XB-qIw75FM5fDKzlWldBEOJBU_My_K6DfVhFg4nat_Ada1RJWjR4fzI9yvwGjg8efkNHRbOU-0GcgKdHpiI7uBEuQ408HoDrbB7ojBD6F_Ol2lqlS3LYSAFTT-5YWkmbTfENpOOUhaFO3BRzF8bFXPQxvVPCVMGnle0d99C-i4Q";
        instance.soeAppId = @"";
        instance.hcmAppId = @"";
    });
    return instance;
}
@end
