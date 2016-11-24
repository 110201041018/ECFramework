//
//  ECShaker.h
//  ECLib
//
//  Created by 陈冠杰 on 16/7/13.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ECShaker : NSObject <CAAnimationDelegate>

-(instancetype)initWithView:(UIView *)view;
-(instancetype)initWithViewsArray:(NSArray *)viewsArray;


-(void)shake;
-(void)shakeWithDuration:(NSTimeInterval)duration completion:(void(^)())completion;


@end
