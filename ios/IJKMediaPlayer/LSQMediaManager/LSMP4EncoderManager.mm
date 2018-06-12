





//
//  LSMP4EncoderManager.m
//  IJKMediaDemo
//
//  Created by 赖双全 on 2018/6/12.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "LSMP4EncoderManager.h"
#import "MP4Encoder.h"

#define LSDocumentsURL        [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]
#define LSDocumentsPath       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#define LSDefaultMp4Url       [LSDocumentsPath stringByAppendingPathComponent:@"h264.mp4"]


@interface LSMP4EncoderManager()
@property (nonatomic, assign) MP4FileHandle mp4FileHandle;
@property (nonatomic, assign) MP4Encoder *mp4encoder;
@end

@implementation LSMP4EncoderManager

- (instancetype)initWith:(int)width height:(int)height{
    if (self = [super init]) {
        _width = width;
        _heigth = height;
        _mp4encoder = new MP4Encoder;
    }
    return self;
    
}

- (void)createMP4File:(NSString *)fileName{
    if (!fileName) {
        fileName = LSDefaultMp4Url;
    }
    if (!_mp4encoder) {
        _mp4encoder = new MP4Encoder;
    }
    
    self.mp4FileHandle = self.mp4encoder->CreateMP4File([fileName UTF8String], self.width, self.heigth, 90000, 25);
    
}

- (void)writeH264Data:(unsigned char *)pData size:(int)size{
    self.mp4encoder->WriteH264Data(self.mp4FileHandle, pData, size);
    
}


- (void)closeMP4File{
    self.mp4encoder->CloseMP4File(self.mp4FileHandle);
    
}



@end
