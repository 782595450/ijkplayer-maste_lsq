





//
//  Facerecognition_opencv.m
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/13.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "Facerecognition_opencv.h"
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/ios.h>

using namespace std;
using namespace cv;

@implementation Facerecognition_opencv

// 识别到的人脸预处理  检测并分割出人脸 ORL人脸数据库人脸的大小是92 x 112
- (UIImage *)picturePreprocessing:(UIImage *)picture{
    Mat frame ;
    UIImageToMat(picture, frame);
//    frame = cv::imread([[[NSBundle mainBundle] pathForResource:@"IMG_4430" ofType:@"png"] UTF8String], cv::IMREAD_COLOR);

    CascadeClassifier cascade;
    // 人脸的Haar特征分类器
    NSString *cascadeStr = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    cascade.load([cascadeStr UTF8String]);
    if (cascade.empty()) {
        return nil;
    }
    cv::Size original_size = cascade.getOriginalWindowSize();
    
    std::vector<cv::Rect> faces;
    
    Mat frame_gray;
    //提取 灰度图
    cvtColor(frame, frame_gray, COLOR_BGR2GRAY);
    //  检测人脸并保存在数组里
//    cascade.detectMultiScale(frame_gray, faces, 1.1, 3, CV_HAAR_DO_CANNY_PRUNING, cv::Size(100, 100), cv::Size(500, 500));

    cascade.detectMultiScale(frame_gray, faces, 1.1, 3, CV_HAAR_DO_CANNY_PRUNING, original_size);

    for (size_t i = 0; i < faces.size(); i++) {
        Mat faceROI = frame(faces[i]);
        Mat myface;
        resize(faceROI, myface, cv::Size(92,112));
        return MatToUIImage(myface);
        break;
    }
    
    
    
}



@end
