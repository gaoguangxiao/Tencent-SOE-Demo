//
//  NSData+AESEncryption.h
//  wecloudservice
//
//  Created by gaoguangxiao on 2022/11/27.
//  Copyright © 2022 高广校. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMBase64.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AESEncryption)

+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)key;

+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
