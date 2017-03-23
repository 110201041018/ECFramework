//
//  ECDispatchAction.m
//  ECFramework
//
//  Created by jieliapp on 2017/3/23.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import "ECDispatchAction.h"

@implementation ECDispatchAction




/**
 异步执行内容

 @param block 执行内容
 */
+(void)ecAsyncTaskAction:(DispatchAction)block{
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}


/**
 同步执行

 @param block 执行内容
 */
+(void)ecSyncTaskAction:(DispatchAction)block{
    dispatch_async(dispatch_get_main_queue(), block);
}



/**
 异步执行任务队列，然后汇总

 @param tasks 执行内容列表
 @param block 汇总
 */
+(void)ecAsyncTasksAction:(NSArray*)tasks Final:(DispatchAction)block{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for (DispatchAction action in tasks) {
        dispatch_group_async(group, queue, action);
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), block);
}




/**
 延时执行

 @param sec 延时多少秒
 @param block 执行的内容
 */
+(void)ecDelayAction:(NSTimeInterval)sec Task:(DispatchAction)block{
    /*--- 延时执行 ---*/
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


/**
 执行一次

 @param block 执行的内容
 */
+(void)ecTaskOnceAction:(DispatchAction)block{
    /*--- 一次性执行 ---*/
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, block);
}


/**
 执行某段代码片段N次

 @param block 执行的内容
 @param current 执行多少次
 */
+(void)ecTaskAction:(DispatchAction)block WithCurrent:(int)current{
    
    dispatch_apply(current, dispatch_get_global_queue(0,0), block);
    
}


@end
