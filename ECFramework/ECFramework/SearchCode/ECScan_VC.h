//
//  ECScan_VC.h
//  
//
//  Created by 陈冠杰 on 16/7/15.
//  Copyright © 2016年 EzioChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface ECScan_VC : UIViewController

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,weak)   UIView           *maskView;
@property (nonatomic,strong) UIView         *scanWindow;
@property (nonatomic,strong) UIImageView    *scanNetImageView;


@end
