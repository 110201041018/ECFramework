//
//  ECopenGLView.h
//  ECFramework
//
//  Created by Ezio on 2019/4/28.
//  Copyright © 2019 EzioChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECopenGLYUVRenderView : UIView

- (void)setVideoSize:(NSInteger)width height:(NSInteger)height;

- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h;

- (void)clearFrame;

@end

NS_ASSUME_NONNULL_END
