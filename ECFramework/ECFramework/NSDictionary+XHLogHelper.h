//
//  NSDictionary+XHLogHelper.h
//  RegisterDemo
//
//  Created by 陈冠杰 on 16/7/27.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (XHLogHelper)

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif


@end
