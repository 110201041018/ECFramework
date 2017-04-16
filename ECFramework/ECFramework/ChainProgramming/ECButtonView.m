//
//  ECButtonView.m
//  ECFramework
//
//  Created by jieliapp on 2017/4/16.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import "ECButtonView.h"

@implementation ECButtonView

- (ChainButtonTitleBlock)titleName{

    return ^ECButtonView *(NSString *titleName){
        
        [self setTitle:titleName forState:UIControlStateNormal];
        return self;
        
    };
    
}



- (ChainButtonImageBlock)imageName{

    return ^ECButtonView *(NSString *aName){
        
        [self setImage:[UIImage imageNamed:aName] forState:UIControlStateNormal];
        return self;
        
    };
}



-(ChainButtonIntergerBlock)titleFont{

    return ^ECButtonView *(NSUInteger aNumber){
        
        self.titleLabel.font = [UIFont systemFontOfSize:aNumber];
        return self;
        
    };
}


- (ChainButtonColorBlock)textColor{

    return ^ECButtonView *(UIColor *aColor){
        
        [self setTitleColor:aColor forState:UIControlStateNormal];
        return self;
        
    };
}


- (ChainButtonFrameBlock)btnFrame{

    return ^ECButtonView *(CGRect frame){
    
        [self setFrame:frame];
        return self;
    };
    
}



+ (ECButtonView *)makeECButton:(void (^)(ECButtonView *))block{
    
    
    ECButtonView *button = [[ECButtonView alloc] init];
    
    block(button);
    
    return button;
}


@end
