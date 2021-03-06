

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
@interface opencv_ios (){
//    Mat frame;
    
}

@end

@implementation opencv_ios

// 边缘检测
- (UIImage *)imageCanny:(unsigned char*)bgrData width:(int)width heigth:(int)heitht{
    Mat frame;
    frame.create(cv::Size(width,heitht), CV_8UC3);
    frame.data = bgrData;
    Mat dstImage;
    cvtColor(frame, dstImage, CV_BGR2GRAY);
    blur(dstImage, dstImage, cv::Size(7,7));
    Canny(dstImage, dstImage, 0, 30);
    
    return MatToUIImage(dstImage);
    
}

// 图像腐蚀
- (UIImage *)element:(unsigned char*)bgrData width:(int)width heigth:(int)heitht{
    Mat frame;
    frame.create(cv::Size(width,heitht), CV_8UC3);
    frame.data = bgrData;
    

    // 设置腐蚀的形状大小
    Mat element = getStructuringElement(MORPH_CROSS, cv::Size(7,7));
    Mat dstImage;
    // 腐蚀函数
    erode(frame, dstImage, element);
    return MatToUIImage(dstImage);
    
}


// 图像模糊
- (UIImage *)blur:(unsigned char*)bgrData width:(int)width heigth:(int)heitht{
    Mat frame;
    frame.create(cv::Size(width,heitht), CV_8UC3);
    frame.data = bgrData;

    Mat dstImage;
    // 进行均值滤波操作
    blur(frame, dstImage, cv::Size(1,1));   // size只能是整数，越大模糊效果越好
    
    return MatToUIImage(dstImage);
    
}

// 图像插值
- (UIImage *)cvInter:(unsigned char*)bgrData width:(int)width heigth:(int)heitht{
    Mat frame;
    frame.create(cv::Size(width,heitht), CV_8UC3);
    frame.data = bgrData;
    
    Mat dstImage;
    // 进行差值操作
    resize(frame, dstImage,cv::Size(width*3.5,heitht*3.5), 0, 0,CV_INTER_CUBIC);

    return MatToUIImage(dstImage);
    
}

@end
