//
//  RSShowWaveView.h
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"
@interface RSShowWaveView : UIView

@property (nonatomic, strong) NSMutableArray *pointArr;

- (void)startWave;
@end
