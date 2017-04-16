//
//  ECButtonView.h
//  ECFramework
//
//  Created by jieliapp on 2017/4/16.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECButtonView;

typedef ECButtonView*(^ChainButtonTitleBlock)(NSString *title);
typedef ECButtonView*(^ChainButtonImageBlock)(NSString *aName);
typedef ECButtonView*(^ChainButtonIntergerBlock)(NSUInteger aNumber);
typedef ECButtonView*(^ChainButtonColorBlock)(UIColor *aColor);
typedef ECButtonView*(^ChainButtonFrameBlock)(CGRect aframe);

@interface ECButtonView : UIButton

- (ChainButtonTitleBlock)titleName;
- (ChainButtonImageBlock)imageName;
- (ChainButtonIntergerBlock)titleFont;
- (ChainButtonColorBlock)textColor;
- (ChainButtonFrameBlock)btnFrame;


+ (ECButtonView *)makeECButton:(void (^)(ECButtonView *))block;

@end
