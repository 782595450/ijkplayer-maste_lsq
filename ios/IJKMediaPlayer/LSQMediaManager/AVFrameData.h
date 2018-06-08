//
//  AVFrameData.h
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/8.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVFrameData : NSObject
@property (nonatomic, strong) NSMutableData *colorPlane0;
@property (nonatomic, strong) NSMutableData *colorPlane1;
@property (nonatomic, strong) NSMutableData *colorPlane2;
@property (nonatomic, strong) NSNumber      *lineSize0;
@property (nonatomic, strong) NSNumber      *lineSize1;
@property (nonatomic, strong) NSNumber      *lineSize2;
@property (nonatomic, strong) NSNumber      *width;
@property (nonatomic, strong) NSNumber      *height;
@property (nonatomic, strong) NSDate        *presentationTime;
@property (nonatomic, assign) unsigned char * data0;
@property (nonatomic, assign) unsigned char  *data1;
@property (nonatomic, assign) unsigned char  *data2;
@end
