//
//  ECLabelView.m
//  ECFramework
//
//  Created by jieliapp on 2017/4/19.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import "ECLabelView.h"

@implementation ECLabelView

- (ECLabelStringBlock)titleString{

    return ^ECLabelView *(NSString *str){
        self.text = str;
        return self;
    };
}

- (ECLabelIntergerBlock)titleFontSize{
    return ^ECLabelView *(NSUInteger fontSize){
        self.font = [UIFont systemFontOfSize:fontSize];
        return self;
    };
}



- (ECLabelAlignBlock)labelAlignment{

    return ^ECLabelView *(NSTextAlignment type){
        self.textAlignment = type;
        return self;
        
    };
}


- (ECLabelFrameBlock)labelFrame{
    return ^ECLabelView *(CGRect aFrame){
        self.frame = aFrame;
        return self;
    };
}


- (ECLabelColorBlock)labelColor{

    return ^ECLabelView *(UIColor *acolor){
        
        self.textColor = acolor;
        
        return  self;
    };
}


@end
