//
//  LSMP4EncoderManager.h
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/12.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSMP4EncoderManager : NSObject

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int heigth;

//- (instancetype)initWith:(int)width height:(int)height;
- (void)createMP4File:(NSString *)fileName;
- (void)writeH264Data:(unsigned char *)pData size:(int)size;
- (void)closeMP4File;

@end
