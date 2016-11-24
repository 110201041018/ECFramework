//
//  ECLog.h
//  ECFramework
//
//  Created by 陈冠杰 on 23/11/2016.
//  Copyright © 2016 EzioChen. All rights reserved.
//

#import <Foundation/Foundation.h>


#define logcontrol 1

#define ECLogs(...) if(logcontrol == 1) NSLog(__VA_ARGS__)

@interface ECLog : NSObject

@end
