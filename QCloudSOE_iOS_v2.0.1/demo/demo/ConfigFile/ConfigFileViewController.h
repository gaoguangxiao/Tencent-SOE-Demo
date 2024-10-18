//
//  ConfigFileViewController.h
//  demo
//
//  Created by 高广校 on 2024/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigFileViewController : UIViewController

///返回是否需要刷新界面
@property (nonatomic, copy) void(^isSaveAudios)(void);
@end

NS_ASSUME_NONNULL_END
