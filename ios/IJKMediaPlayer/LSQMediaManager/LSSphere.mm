//
//  LSSphere.m
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/9.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "LSSphere.h"
#import <opencv2/opencv.hpp>

#define PI 3.1415926



@implementation LSSphere
int x_dot = 177;         //全景图像的圆心X坐标
int y_dot = 130;         //全景图像的圆心X坐标
int Width;
int Height;
int inner_Radius = 50;   //全景图像的内径
int outer_Radius = 100;  //全景图像的外径

- (void)geData{
    
    Width = (int)(2 * PI * outer_Radius);   //展开图像的宽
    Height = outer_Radius - inner_Radius; //展开图像的高

}

// 获取角度
double GetAngle(int i_ExpandWidth,int i_ExpandHeight)
{
    double dw_Angle = (double)i_ExpandWidth/(double)outer_Radius ;
    return dw_Angle;
}

// 获取半径
int GetRadius(int i_ExpandWidth,int i_ExpandHeight){
    return i_ExpandHeight ;
}

- (CGPoint)ocfindPoint:(double)dw_Angle ofRandius:(double)i_Radius{
    double x,y;
    i_Radius += inner_Radius;
    x = i_Radius * cos(dw_Angle) + x_dot;
    y = i_Radius * sin(dw_Angle) + y_dot;
    return CGPointMake(x, y);
}

CvPoint FindPoint(double dw_Angle,int i_Radius)
{
    double x,y;
    i_Radius += inner_Radius;
    x = i_Radius * cos(dw_Angle) + x_dot;
    y = i_Radius * sin(dw_Angle) + y_dot;
    CvPoint pt = {(int)x,(int)y};
    
    return pt;
}

//- (unsigned char *)getRGB:(int)x pointy:(int)y data:(unsigned char*)framedata{
//    unsigned char *rgbData = &(framedata+x*y)[x*3];
//    return rgbData;
//
//}

uchar* GetRGB(int x,int y,IplImage* src)
{
    uchar* temp_src=&((uchar*)(src->imageData + src->widthStep * y))[x * 3];
    return temp_src;
}


- (char *)change:(unsigned char *)data{
    int i,j;
    double dw_Angle;
    int i_Radius;
    CvPoint pt;
    IplImage* src,* dst;
    NSString *path;
    path =  [[NSBundle mainBundle] pathForResource:@"1123" ofType:@"png"];


    src = cvLoadImage([path UTF8String]);
    dst = cvCreateImage(cvSize(Width,Height),8,3);
    dst->origin = 0;
    cvZero(dst);
    for(i = 0 ; i < Width ; i++){
        for(j = 0 ; j < Height ; j++)
        {
            dw_Angle = GetAngle(i,j);
            i_Radius = GetRadius(i,j);
            pt = FindPoint( dw_Angle, i_Radius);
            uchar* temp_src = GetRGB( pt.x,pt.y,src);
            ((uchar*)(dst->imageData + dst->widthStep * j))[i * 3] = temp_src[0];
            ((uchar*)(dst->imageData + dst->widthStep * j))[i * 3 + 1] = temp_src[1];
            ((uchar*)(dst->imageData + dst->widthStep * j))[i * 3 + 2] = temp_src[2];
            
        }

    }
    return dst->imageData;
    
//    cvSaveImage("dst.bmp", dst);
//    cvNamedWindow( "Image src view", 1 );
//    cvNamedWindow( "Image dst view", 1 );
//    cvShowImage( "Image src view", src );
//    cvShowImage( "Image dst view", dst );
//    cvWaitKey(0);
//    cvDestroyWindow( "Image src view" );
//    cvDestroyWindow( "Image dst view" );
//    cvReleaseImage( &src );
//    cvReleaseImage( &dst );
}

@end
