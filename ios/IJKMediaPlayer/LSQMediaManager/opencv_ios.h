//
//  opencv_ios.h
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/12.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface opencv_ios : NSObject

// 边缘检测
- (UIImage *)imageCanny:(unsigned char*)bgrData width:(int)width heigth:(int)heitht;

// 图像腐蚀
- (UIImage *)element:(unsigned char*)bgrData width:(int)width heigth:(int)heitht;

// 图像模糊
- (UIImage *)blur:(unsigned char*)bgrData width:(int)width heigth:(int)heitht;

@end
