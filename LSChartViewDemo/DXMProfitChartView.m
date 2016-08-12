//
//  DXMProfitChartView.m
//  dxmobile
//
//  Created by Liusui on 16/7/7.
//  Copyright © 2016年 Shanghai Elephant Financial Services Co., Ltd. All rights reserved.
//

#import "DXMProfitChartView.h"

static CGRect myFrame;
static int count;   // 点个数，x轴格子数
static int yCount;  // y轴格子数
static CGFloat everyX;  // x轴每个格子宽度
static CGFloat everyY;  // y轴每个格子高度
static CGFloat maxY;    // 收益或亏损最大的y值
static CGFloat allH;    // 整个图表高度
static CGFloat allW;    // 整个图表宽度
static int rowX;       //第几行是x轴
static CGFloat intervalY;   //y轴的区间
static CGFloat const columnWidth = 13;  //柱状的宽度
static CGFloat const labelX = 50;  //y轴导航label宽度
static CGFloat upHeight; //正区间高度
static CGFloat downHeight; //负区间高度
#define UPSHAFTCOLOR [UIColor redColor]   //正轴颜色
#define DOWNSHAFTCOLOR [UIColor greenColor]   //负轴颜色
@implementation DXMProfitChartView

- (void)awakeFromNib{
    [super awakeFromNib];
    CGRect frame = self.bgView.frame;
    CGRect bounds = [UIScreen mainScreen].bounds;
    myFrame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width - 30, 180);
    
    self.isShowLine = YES;
    self.isShowPillar = YES;
    self.isShowValue = NO;
    
    self.yValues = @[@100, @-100, @200,@1000,@30,@-300,@-1000,@2000,@60,@-800];
    [self drawChart];
}

#pragma mark - Private Methods
//柱状图起始坐标
- (CGPoint)columnPointWithIndex:(int)i{
    float maxValue = [[_yValues valueForKeyPath:@"@max.floatValue"] floatValue];
    CGPoint point;
    if (maxValue > 0) {
        point = CGPointMake(labelX + everyX * i + (everyX - columnWidth) / 2, (1 - [self.yValues[i] floatValue] / (intervalY * rowX)) * upHeight);
    } else{
        point = CGPointMake(labelX + everyX * i + (everyX - columnWidth) / 2, - [self.yValues[i] floatValue] / intervalY * everyY);
    }
    return point;
}

- (CAShapeLayer *)chartLayer:(UIBezierPath *)path{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    return layer;
}

#pragma mark - 计算
- (void)doWithCalculate{
    if (!self.yValues || !self.yValues.count) {
        return;
    }
    intervalY = 500;
    float maxValue = [[_yValues valueForKeyPath:@"@max.floatValue"] floatValue];
    float minValue = [[_yValues valueForKeyPath:@"@min.floatValue"] floatValue];
    yCount = minValue < 0 ? (ceilf(maxValue / intervalY) + ceilf(-minValue / intervalY) + 1) : ceilf(maxValue / intervalY) + 1;
    while (yCount > 8) {
        intervalY *= 2;
        yCount = minValue < 0 ? (ceilf(maxValue / intervalY) + ceilf(-minValue / intervalY) + 1) : ceilf(maxValue / intervalY) + 1;
    }
    while (yCount < 5) {
        intervalY /= 2;
        yCount = minValue < 0 ? (ceilf(maxValue / intervalY) + ceilf(-minValue / intervalY) + 1) : ceilf(maxValue / intervalY) + 1;
    }
    
    maxY = maxValue > -minValue ? ceilf(maxValue / intervalY) * intervalY : ceilf(-minValue / intervalY) * intervalY;
    count = (int)self.yValues.count;
    allH = CGRectGetHeight(myFrame);
    allW = CGRectGetWidth(myFrame) - labelX;
    everyX = allW / count;
    everyY = allH / yCount;
    rowX = ceilf(maxValue / intervalY);
    upHeight = rowX * everyY;
    downHeight = (yCount - rowX -1) * everyY;
}

#pragma mark - 添加钱的label
- (void)drawLabels{
    //Y轴
    for(int i = 0; i <= yCount - 1; i ++){
        int price = (rowX - i) * intervalY;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, everyY * i - everyY / 2, labelX, everyY)];
        lbl.textColor = [UIColor grayColor];
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.text = [NSString stringWithFormat:@"%d元", price];
        [self.bgView addSubview:lbl];
    }
}

#pragma mark - 画网格
- (void)drawLines{
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 虚线
    for (int i = 0; i < yCount; i ++) {
        if (i != rowX) {
            [path moveToPoint:CGPointMake(labelX, everyY * i)];
            [path addLineToPoint:CGPointMake(allW + labelX,  everyY * i)];
        }
    }
    CAShapeLayer *layer = [self chartLayer:path];
    [layer setLineJoin:kCALineJoinRound];
    [layer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
      [NSNumber numberWithInt:2],nil]];
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.fillColor = [UIColor grayColor].CGColor;
    layer.lineWidth = 1;
    [self.bgView.layer addSublayer:layer];
    
}

#pragma mark - 画x轴
- (void)drawXLine{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(labelX, upHeight)];
    [path addLineToPoint:CGPointMake(allW + labelX, upHeight)];
    CAShapeLayer *layer = [self chartLayer:path];
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.fillColor = [UIColor grayColor].CGColor;
    layer.lineWidth = 1;
    [self.bgView.layer addSublayer:layer];
}

#pragma mark - 画柱状图
- (void)drawPillar{
    for (int i = 0; i < count; i ++) {
        CGPoint point = [self columnPointWithIndex:i];
        CGRect rect = CGRectMake(point.x, point.y, columnWidth, upHeight - point.y);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        CAShapeLayer *layer = [self chartLayer:path];
        layer.strokeColor = [_yValues[i] floatValue] >= 0 ? UPSHAFTCOLOR.CGColor : DOWNSHAFTCOLOR.CGColor;
        layer.fillColor =  [_yValues[i] floatValue] >= 0 ? UPSHAFTCOLOR.CGColor : DOWNSHAFTCOLOR.CGColor;
        [self.bgView.layer addSublayer:layer];
    }
}

#pragma mark - 画点
- (void)drawPoint:(PointType)type{
    // 画点
    switch (type) {
        case PointType_Rect:
            for (int i = 0; i < count; i ++) {
                CGPoint point = [self columnPointWithIndex:i];
                CAShapeLayer *layer = [[CAShapeLayer alloc] init];
                layer.frame = CGRectMake(point.x + columnWidth/2  - 2.5, point.y - 2.5, 5, 5);
                layer.backgroundColor = [UIColor yellowColor].CGColor;
                [self.bgView.layer addSublayer:layer];
            }
            break;
            
        case PointType_Circel:
            for (int i = 0; i < count; i ++) {
                CGPoint point = [self columnPointWithIndex:i];
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x + columnWidth/2  - 2.5, point.y - 2.5, 5, 5) cornerRadius:2.5];
                CAShapeLayer *layer = [self chartLayer:path];
                layer.strokeColor = [UIColor yellowColor].CGColor;
                layer.fillColor = [UIColor yellowColor].CGColor;
                [self.bgView.layer addSublayer:layer];
            }
            
            break;
    }
}

#pragma mark - 画折线/曲线
- (void)drawFoldLineOrCurve:(LineChartType)type{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = [self columnPointWithIndex:0];
    [path moveToPoint:CGPointMake(point.x + columnWidth / 2, point.y)];
    switch (type) {
        case LineChartType_Straight:
            for (int i = 1; i < count; i ++) {
                CGPoint nextPoint = [self columnPointWithIndex:i];
                [path addLineToPoint:CGPointMake(nextPoint.x + columnWidth / 2, nextPoint.y)];
            }
            break;
        case LineChartType_Curve:
            
            for (int i = 0; i < count; i ++) {
                if (i + 1 == count)
                    break;
                CGPoint prePoint = CGPointMake([self columnPointWithIndex:i].x + columnWidth / 2, [self columnPointWithIndex:i].y);
                CGPoint nowPoint = CGPointMake([self columnPointWithIndex:i + 1].x + columnWidth / 2, [self columnPointWithIndex:i + 1].y);
                
                // 两个控制点的两个x中点为X值，preY、nowY为Y值；
                
                [path addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x + prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
            }
            break;
            
    }
    
    CAShapeLayer *layer = [self chartLayer:path];
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    [self.bgView.layer addSublayer:layer];
}

#pragma mark - 显示数据
- (void)drawValues{
    for (int i = 0; i < count; i ++) {
        float maxValue = [[_yValues valueForKeyPath:@"@max.floatValue"] floatValue];
        if ([_yValues[i] floatValue] != maxValue) {
            CGPoint point = [self columnPointWithIndex:i];
            UILabel *lbl = [[UILabel alloc] init];
            if ([_yValues[i] floatValue] >= 0) {
                lbl.frame = CGRectMake(point.x - 10, point.y - 20, columnWidth + 20, 20);
            } else {
                lbl.frame = CGRectMake(point.x - 10, point.y, columnWidth + 20, 20);
            }
            lbl.textColor = [UIColor grayColor];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = [NSString stringWithFormat:@"%@",self.yValues[i]];
            lbl.font = [UIFont systemFontOfSize:12];
            lbl.adjustsFontSizeToFitWidth = YES;
            [self.bgView addSubview:lbl];
        }
    }
}

#pragma mark - 最多收益指示
- (void)drawMaxProfit{
    NSInteger maxValue = [[_yValues valueForKeyPath:@"@max.intValue"] integerValue];
    int i;
    for (i = 0; i < _yValues.count; i ++) {
        if (maxValue == [_yValues[i] integerValue]) {
            break;
        }
    }
    CGPoint nowPoint = CGPointMake(labelX + everyX * i, (1 - [self.yValues[i] floatValue] / maxY) * allH);
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"最高收益"]];
    imageView.frame = CGRectMake(nowPoint.x + (everyX - columnWidth) / 2, -25, 15, 20);
    [self.bgView addSubview:imageView];
    
    NSString *s = [NSString stringWithFormat:@"最高 %ld 元",(long)maxValue];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:s];
    [attStr addAttribute:NSForegroundColorAttributeName value:UPSHAFTCOLOR range:NSMakeRange(3, s.length - 5)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:NSMakeRange(3, s.length - 5)];
    UILabel *maxlabel = [[UILabel alloc]init];
    if (CGRectGetMaxX(imageView.frame) + 120 > CGRectGetWidth([UIScreen mainScreen].bounds)) {
        maxlabel.frame = CGRectMake(CGRectGetMinX(imageView.frame) - 125, -25, 120, 20);
        maxlabel.textAlignment = NSTextAlignmentRight;
    } else {
        maxlabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 5, -25, 120, 20);
    }
    maxlabel.font = [UIFont systemFontOfSize:12];
    maxlabel.textColor = [UIColor grayColor];
    maxlabel.attributedText = attStr;
    [self.bgView addSubview:maxlabel];
}

#pragma mark - 整合 画图表
- (void)drawChart{
    // 计算赋值
    [self doWithCalculate];
    NSArray *layers = [self.bgView.layer.sublayers mutableCopy];
    for (CAShapeLayer *layer in layers) {
        [layer removeFromSuperlayer];
    }
    // 画柱状图
    if(self.isShowPillar){
        [self drawPillar];
    }
    // 画网格线
    if (self.isShowLine) {
        [self drawLines];
        [self drawXLine];
    }
    // 添加文字
    [self drawLabels];
    //最多收益指示
    [self drawMaxProfit];
    //显示数据
    [self drawValues];
    //画点
    [self drawPoint:PointType_Circel];
    //画折线/曲线
    [self drawFoldLineOrCurve:LineChartType_Curve];
}

@end
