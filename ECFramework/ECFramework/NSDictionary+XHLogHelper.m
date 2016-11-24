//
//  NSDictionary+XHLogHelper.m
//  RegisterDemo
//
//  Created by 陈冠杰 on 16/7/27.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import "NSDictionary+XHLogHelper.h"

@implementation NSDictionary (XHLogHelper)

#if DEBUG
- (NSString *)descriptionWithLocale:(nullable id)locale{
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}
#endif

@end
