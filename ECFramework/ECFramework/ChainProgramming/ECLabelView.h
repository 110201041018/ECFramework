//
//  ECLabelView.h
//  ECFramework
//
//  Created by jieliapp on 2017/4/19.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECLabelView;

typedef ECLabelView*(^ECLabelStringBlock)(NSString *aString);
typedef ECLabelView*(^ECLabelIntergerBlock)(NSUInteger aNumber);
typedef ECLabelView*(^ECLabelAlignBlock)(NSTextAlignment type);
typedef ECLabelView*(^ECLabelFrameBlock)(CGRect frame);
typedef ECLabelView*(^ECLabelColorBlock)(UIColor *aColor);

@interface ECLabelView :UILabel

- (ECLabelStringBlock)titleString;
- (ECLabelIntergerBlock)titleFontSize;
- (ECLabelAlignBlock)labelAlignment;
- (ECLabelFrameBlock)labelFrame;
- (ECLabelColorBlock)labelColor;


@end
