//
//  RSShowWaveView.m
//  FFTDemo
//
//  Created by sensology on 2016/11/2.
//  Copyright © 2016年 智觅智能. All rights reserved.
//

#import "RSShowWaveView.h"
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width

@interface RSShowWaveView ()

//@property (nonatomic, strong)MOTimeTableView *timeView;
@end

@implementation RSShowWaveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pointArr = [[NSMutableArray alloc]init];

        self.backgroundColor = [UIColor systemGray4Color];
        
        _pointArr = [NSMutableArray new];
//        [self initView];
    }
    return self;
}

//-(void)initView{
    
//    self.timeView = [[MOTimeTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//    self.timeView.frame = CGRectMake(0, 0, self.frame.size.width, 20);
//    [self addSubview:self.timeView];
    
    //
//    UIView *centerLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
//    centerLine.backgroundColor = UIColor.yellowColor;
//    [self addSubview:centerLine];
//}

//柱形
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawLine];
}

- (void)drawLine {
    if (!self.pointArr||[self.pointArr count] == 0) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    UIFont *font = [UIFont systemFontOfSize:12]; // 设置文字大小为24点
    UIColor *textColor = [UIColor blueColor];
    UIColor *backTextColor = [UIColor whiteColor];
    float titleWidth = 100;
    
    CGFloat cheight = height;
    float per = 10;
    float heightPer = cheight/per;
    
//    float channelCenterY = self.frame.size.height - 1;//中间线是
    for (NSInteger i = 0; i < self.pointArr.count; i++){
        MusicModel *point = self.pointArr[i];
        float val = point.value + 1;//
//        NSLog(@"db is：%f",point.value);
        if (val <= 1) {
            val = 1;
        }
        float x = 50 + i * 2;
        CGContextMoveToPoint(context, x, cheight);
        CGContextAddLineToPoint(context, x, cheight - val);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
        CGContextStrokePath(context);
    }

    //绘制
    for (NSInteger i = 0; i <= per; i++){
        float val = i * heightPer;
        float position = cheight - val;
        NSString *value = [NSString stringWithFormat:@"%.0f",val];
        [value drawInRect:CGRectMake(0, position - 12, titleWidth, 12) withAttributes:@{NSFontAttributeName: font,
                                                                                NSForegroundColorAttributeName:textColor,
                                                                                NSBackgroundColorAttributeName:backTextColor}];

        // 设置虚线样式
        CGFloat dashPattern[] = {4, 2}; // 4点长度的线段和2点长度的空白
        CGContextSetLineDash(context, 0, dashPattern, 2); // 第一个参数是起始偏移量
        
        // 绘制线条
        CGContextMoveToPoint(context, 0, position);
        CGContextAddLineToPoint(context, width,position);

        // 设置线条的颜色和宽度
//        if (i == 0) {
//            CGContextSetStrokeColorWithColor(context, UIColor.blueColor.CGColor);
//        } else {
            CGContextSetStrokeColorWithColor(context, UIColor.grayColor.CGColor);
//        }
        CGContextSetLineWidth(context, 1.0);
        
        // 绘制
        CGContextStrokePath(context);
    }
//    CGContextSetLineWidth(context, 1.0);
//    float channelCenterY = imageSize.height / 2;
//    for (int i = 0; i < [self.pointArr count]; i++) {
//        CGPoint point = [self.pointArr[i] CGPointValue];
//
//        if (i%10 == 0) {
//
//            //柱形图顶部线段
////            CGContextAddLineToPoint(context, prePoint.x, point.y);
////            CGContextAddLineToPoint(context, point.x, point.y);
////            CGContextStrokePath(context);
//
//            float  docsSpace = 10 ;
//
////            CGContextMoveToPoint(context, x, channelCenterY - val / 2.0);
////            CGContextAddLineToPoint(context, x, channelCenterY + val / 2.0);
//            //动态圆柱体
//            CGContextMoveToPoint(context, prePoint.x,prePoint.y);
//            CGContextAddLineToPoint(context, prePoint.x, point.y);
//            CGContextAddLineToPoint(context, point.x + docsSpace, point.y);
//            if (i > 765) {
//                [K_RGBColor(240, 70, 135) setFill];
////                [[UIColor colorWithRed:(255 -(i - 765))/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] setFill];
//            }
//            else{
////                [K_RGBColor(240, 70, 135) setFill];
//                [[UIColor colorWithRed:(i<255?i:255.0)/255.0 green:((i>255)?((i-255)>255?255:(i-255)):0.0)/255.0 blue:(i>510?(i - 510):0.0)/255.0 alpha:1.0] setFill];
//            }
//            CGContextAddLineToPoint(context, point.x + docsSpace, height);
//            CGContextAddLineToPoint(context, prePoint.x, height);
//            CGContextFillPath(context);
////            CGContextMoveToPoint(context, point.x+ docsSpace,point.y);
//            prePoint = point;
//        }
    
//    }
//    [[UIColor blueColor] setStroke];
//    CGContextSetLineWidth(context, 1.0);
//    CGContextAddLineToPoint(context, ScreenWidth - 10, self.frame.size.height/2.0);
//    CGContextAddLineToPoint(context, ScreenWidth - 10, height);
//    CGContextAddLineToPoint(context, 10, height);
//    CGContextAddLineToPoint(context, 10, self.frame.size.height/2.0);
//    CGContextStrokePath(context);
}

- (void)drawLine1 {
        
    CGRect rect = self.frame;
        CGContextRef context = UIGraphicsGetCurrentContext(); //当前上下文
        CGContextScaleCTM(context, 0.8, 0.8);                 //绘制区域相对于当前区域的比例，相当于缩放
        
        //缩放后将绘制图像移动
        CGFloat xOffset = self.bounds.size.width - (self.bounds.size.width*0.8);
        CGFloat yOffset = self.bounds.size.height - (self.bounds.size.height*0.8);
        CGContextTranslateCTM(context, xOffset/2, yOffset/2);
        
        NSArray *filerSamples = self.pointArr;      //得到绘制数据
        CGFloat midY = CGRectGetMidY(rect);                                //得到中心y的坐标
        CGMutablePathRef halfPath = CGPathCreateMutable();                 //绘制路径
        CGPathMoveToPoint(halfPath, nil, 0.0f, midY);      //在路径上移动当前画笔的位置到一个点，这个点由CGPoint 类型的参数指定。

        for (NSUInteger i = 0; i < filerSamples.count; i ++) {
            
            float sample = [filerSamples[i] floatValue];
            CGPathAddLineToPoint(halfPath, NULL, i, midY - sample);   //从当前的画笔位置向指定位置（同样由CGPoint类型的值指定）绘制线段
        }
        
        CGPathAddLineToPoint(halfPath, NULL, filerSamples.count, midY); //重置起点

        //实现波形图反转
        CGMutablePathRef fullPath = CGPathCreateMutable();//创建新路径
        CGPathAddPath(fullPath, NULL, halfPath);          //合并路径
        
        CGAffineTransform transform = CGAffineTransformIdentity; //反转
        //反转配置
        transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(rect));
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        CGPathAddPath(fullPath, &transform, halfPath);
        
        //将路径添加到上下文中
        CGContextAddPath(context, fullPath);
        //绘制颜色
        CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
        //开始绘制
        CGContextDrawPath(context, kCGPathFill);
        
        //移除
        CGPathRelease(halfPath);
        CGPathRelease(fullPath);
//        [super drawRect:rect];

}

//波形
//-(void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    if (!self.pointArr) {
//        return;
//    }
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [[UIColor blueColor] setStroke];
//    CGContextSetLineWidth(context, 1.0);
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 0, self.frame.size.height/2.0);
//    for (int i = 0; i < [self.pointArr count]; i++) {
//        MusicModel *point = self.pointArr[i];
////        CGPoint point = [self.pointArr[i] CGPointValue];
////        CGContextAddLineToPoint(context, point.x, point.y);
//    }
//    CGContextAddLineToPoint(context, ScreenWidth, self.frame.size.height/2.0);
//    CGContextStrokePath(context);
//}

//- (MOTimeTableView *)timeView {
//    if (!_timeView) {
//        _timeView = [[MOTimeTableView alloc]init];
//    }
//    return _timeView;
//}

@end
