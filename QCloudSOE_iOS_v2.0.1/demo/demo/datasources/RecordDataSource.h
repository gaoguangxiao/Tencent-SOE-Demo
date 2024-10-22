//
//  RecordDataSource.h
//  demo
//
//  Created by tbolp on 2023/3/24.
//

#import <Foundation/Foundation.h>
#import <QCloudSOE/TAIOralDataSource.h>
#import "AVFoundation/AVFoundation.h"
#import "RecordFileHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordDataSource : NSObject<TAIOralDataSource>

@property (nonatomic, strong) RecordFileHandler *fileHandler;
@end

NS_ASSUME_NONNULL_END
