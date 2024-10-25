//
//  FileDataSourceHandle.h
//  demo
//
//  Created by 高广校 on 2024/10/25.
//

#import <Foundation/Foundation.h>
#import <QCloudSOE/TAIOralDataSource.h>
#import <QCloudSOE/TAIOralListener.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAIDataSourceHandle : NSObject

- (void)build:(id<TAIOralDataSource>)source listener:(id<TAIOralListener>)listener;

- (void)stop;
@end

NS_ASSUME_NONNULL_END
