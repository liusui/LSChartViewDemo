//
//  DXMProfitChartView.h
//  dxmobile
//
//  Created by Liusui on 16/7/7.
//  Copyright © 2016年 Shanghai Elephant Financial Services Co., Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <XXNibBridge/XXNibBridge.h>
@class DXMCattlePeopleViewModel;

// 线条类型
typedef NS_ENUM(NSInteger, LineChartType) {
    LineChartType_Straight, // 折线
    LineChartType_Curve     // 曲线
};
// 点类型
typedef NS_ENUM(NSInteger, PointType) {
    PointType_Rect,   // 方形
    PointType_Circel   // 圆形
};

@interface DXMProfitChartView : UIView<XXNibBridge>

// y轴值
@property (nonatomic, copy) NSArray *yValues;

@property (nonatomic, assign) bool isShowLine;
@property (nonatomic, assign) bool isShowPillar;
@property (nonatomic, assign) bool isShowValue;
@property (weak, nonatomic) IBOutlet UIView *bgView;

- (void)drawChart;

@end
