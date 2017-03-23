//
//  ECDispatchAction.h
//  ECFramework
//
//  Created by jieliapp on 2017/3/23.
//  Copyright © 2017年 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DispatchAction)();

@interface ECDispatchAction : NSObject

/**
 异步执行内容
 
 @param block 执行内容
 */
+(void)ecAsyncTaskAction:(DispatchAction)block;

/**
 同步执行
 
 @param block 执行内容
 */
+(void)ecSyncTaskAction:(DispatchAction)block;
/**
 异步执行任务队列，然后汇总
 
 @param tasks 执行内容列表
 @param block 汇总
 */
+(void)ecAsyncTasksAction:(NSArray*)tasks Final:(DispatchAction)block;

/**
 延时执行
 
 @param sec 延时多少秒
 @param block 执行的内容
 */
+(void)ecDelayAction:(NSTimeInterval)sec Task:(DispatchAction)block;

/**
执行一次

@param block 执行的内容
*/
+(void)ecTaskOnceAction:(DispatchAction)block;

/**
 执行某段代码片段N次
 
 @param block 执行的内容
 @param current 执行多少次
 */
+(void)ecTaskAction:(DispatchAction)block WithCurrent:(int)current;

@end
