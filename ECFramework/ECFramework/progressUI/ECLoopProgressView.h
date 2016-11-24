//
//  ECLoopProgressView.h
//  ECTools
//
//  Created by 陈冠杰 on 18/11/2016.
//  Copyright © 2016 EzioChen. All rights reserved.
//

#import <UIKit/UIKit.h>

// 起始颜色
#define ECLOOP_STARTCOLOR         [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:238.0/255.0 alpha:1]
// 中间颜色
#define ECLOOP_CENTERCOLOR        [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:238.0/255.0 alpha:1]
// 结束颜色;
#define ECLOOP_ENDCOLOR           [UIColor colorWithRed:40.0/255.0 green:98.0/255.0 blue:238.0/255.0 alpha:1]
// 背景色
#define ECLOOP_BLACKGROUNDCOLOR   [UIColor lightGrayColor]
// 线宽
#define ECLOOP_LINEWIDTH         3
// 起始角度（根据顺时针计算，逆时针则是结束角度）
#define ECLOOP_STARTANGLE       -90
// 结束角度（根据顺时针计算，逆时针则是起始角度）
#define ECLOOP_ENDANGLE         270
// 进度条起始方向（YES为顺时针，NO为逆时针）
#define ECLOOP_CLOCKWISETYPE    YES


typedef NS_ENUM (NSInteger, EClockWiseType) {
    EClockWiseYes,
    EClockWiseNo
};

@interface ECLoopProgressView : UIView

@property (assign, nonatomic) CGFloat persentage;





@end
