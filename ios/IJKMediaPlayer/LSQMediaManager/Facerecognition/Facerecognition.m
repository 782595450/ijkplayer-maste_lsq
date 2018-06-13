//
//  Facerecognition.m
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/13.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "Facerecognition.h"
#define LSDocumentsURL        [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]
#define LSDocumentsPath       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#define LSDefaultMp4Url       [LSDocumentsPath stringByAppendingPathComponent:@"Face"]

@implementation Facerecognition

//创建缓存目录
- (void)createCacheDirectory{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:LSDefaultMp4Url]) {
        [fileManager createDirectoryAtPath:LSDefaultMp4Url withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}


@end
