//
//  ECShaker.m
//  ECLib
//
//  Created by 陈冠杰 on 16/7/13.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import "ECShaker.h"

static NSTimeInterval const eCDefaultDuration = 0.5;
static NSString * const eCShakerAnimationKey = @"eCShakerAnimationKey";

@interface ECShaker ()

@property(nonatomic,strong) NSArray *views;
@property(nonatomic,assign) NSUInteger completedAnimations;
@property(nonatomic,copy) void (^completionBlock)();


@end


@implementation ECShaker

-(instancetype)initWithView:(UIView *)view{

    return [self initWithViewsArray:@[view]];
}


-(instancetype)initWithViewsArray:(NSArray *)viewsArray{

    self = [super init];
    if (self) {
        self.views = viewsArray;
    }
    return self;
}

#pragma mark <Public methods>

-(void)shake{

    [self shakeWithDuration:eCDefaultDuration completion:nil];
    
}


-(void)shakeWithDuration:(NSTimeInterval)duration completion:(void(^)())completion{

    self.completionBlock = completion;
    for (UIView *view in self.views) {
        
        [self addShakeAnimationForView:view withDuration:duration];
        
    }
}


#pragma mark <- Shake Animation ->

-(void)addShakeAnimationForView:(UIView *)view withDuration:(NSTimeInterval)duration{

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = view.transform.tx;
    
    animation.delegate = self;
    animation.duration = duration;
    animation.values = @[ @(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [view.layer addAnimation:animation forKey:eCShakerAnimationKey];
    
}


#pragma mark <CAAnimation Delegate>

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    self.completedAnimations +=1;
    if (self.completedAnimations >= self.views.count) {
        self.completedAnimations = 0;
        if (self.completionBlock) {
            self.completionBlock();
        }
    }

}

@end
