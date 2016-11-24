//
//  ECTools.h
//  ECFramework
//
//  Created by 陈冠杰 on 23/11/2016.
//  Copyright © 2016 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECTools : NSObject

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string;

//十六进制转换成普通字符串
+(NSString *)stringFromHexString:(NSString *)hexString;

//编写一个NSData类型数据
+(NSMutableData*)HexStringToData:(NSString*)str;

//补位专用函数
+(NSString*)addString:(NSString*)string Length:(NSInteger)length OnString:(NSString*)str;

//整型转化为len位的十六进制字符串
+(NSString *)intToHexString:(NSInteger)number length:(NSInteger)len;

//十六进制数据转化为十进制普通整形
+(NSInteger)dataToInt:(NSData *)data;

//十六进制数据转化为十六进制字符串
+(NSString*)dataChangeToString:(NSData*)data;

//数据大小端转换
+(NSData *)dataTransfromBigOrSmall:(NSData *)data;

@end
