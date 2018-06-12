

//
//  opencv_ios.m
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/12.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "opencv_ios.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>

using namespace cv;
@interface opencv_ios ()
{
    Mat frame,edg;
}

@end


@implementation opencv_ios

// 边缘检测
- (UIImage *)imageCanny:(unsigned char*)bgrData width:(int)width heigth:(int)heitht{
//    Mat frame,edg;
    frame.create(cv::Size(width,heitht), CV_8UC3);
    frame.data = bgrData;
    cvtColor(frame, edg, CV_BGR2GRAY);
    blur(edg, edg, cv::Size(7,7));
    Canny(edg, edg, 0, 30);
    
    return MatToUIImage(edg);
    
}

@end
