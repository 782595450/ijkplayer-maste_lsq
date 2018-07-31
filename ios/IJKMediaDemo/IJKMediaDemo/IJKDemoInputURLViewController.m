/*
 * Copyright (C) 2015 Gdier
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "IJKDemoInputURLViewController.h"
#import "IJKMoviePlayerViewController.h"
#import "LSPlayerMovieDecoder.h"
#import "OpenGLView20.h"
#import "LSSphere.h"
#import "opencv_ios.h"
#import "LSMP4EncoderManager.h"
#import "Facerecognition_opencv.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"

#define LSScreenWidth  [UIScreen mainScreen].bounds.size.width
#define LSScreenHeight [UIScreen mainScreen].bounds.size.height


@interface IJKDemoInputURLViewController () <UITextViewDelegate,MovieDecoderDelegate>{
    LSPlayerMovieDecoder* decoder;
    OpenGLView20 *_panoplayer;
    unsigned char* m_pBuffer;
    LSSphere *sphere;
    UIImageView *openvcImageView;
    opencv_ios *opencvhandle;
    LSMP4EncoderManager *encoderManager;
    Facerecognition_opencv *faceopencv;
    UISlider *progressSlider;
    UILabel *currentTimeLabel,*durationTimeLabel;
}

@property(nonatomic,strong) IBOutlet UITextView *textView;

@end

@implementation IJKDemoInputURLViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Input URL";
        
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStyleDone target:self action:@selector(onClickPlayButton)]];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"video plugin deallo");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [decoder stop];
    [decoder cleargc];
    decoder.delegate = nil;
    decoder = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];


//    [self openvc];
    
    [self openglplay];
    
//    [self faceOpencv];
    
    
    progressSlider = [[UISlider alloc] init];
    [self.view addSubview:progressSlider];
    progressSlider.frame = CGRectMake(50, LSScreenHeight-100, LSScreenWidth-100, 30);
    
    currentTimeLabel = [UILabel new];
    [self.view addSubview:currentTimeLabel];
    currentTimeLabel.text = @"--:--";
    currentTimeLabel.frame = CGRectMake(0, LSScreenHeight-50, 50, 30);
    
    durationTimeLabel = [UILabel new];
    [self.view addSubview:durationTimeLabel];
    durationTimeLabel.textColor = [UIColor whiteColor];
    durationTimeLabel.text = @"--:--";
    durationTimeLabel.frame = CGRectMake(LSScreenWidth-50, LSScreenHeight-50, 50, 30);
}

- (void)faceOpencv{
    faceopencv = [Facerecognition_opencv new];
    UIImage *image = [faceopencv picturePreprocessing:[UIImage imageNamed:@"IMG_2229.JPG"]];
    int i;
}

- (void)openglplay{
    _panoplayer = [[OpenGLView20 alloc] init];
    _panoplayer.backgroundColor = [UIColor blueColor];
    _panoplayer.frame = CGRectMake(0, 44, LSScreenWidth, LSScreenHeight);
    //    NSLog(@" frame size %f,%f",_panoplayer.frame.size.width,_panoplayer.frame.size.height);
    [self.view addSubview:_panoplayer];

}

- (void)sphere{
    // 全景测试
    sphere = [LSSphere new];
    [sphere change:nil];
}

- (void)openvc{
    // opencv测试
    openvcImageView = [UIImageView new];
    [self.view addSubview:openvcImageView];
    openvcImageView.frame = CGRectMake(0, 44, LSScreenWidth, LSScreenHeight);

    opencvhandle = [opencv_ios new];
    
}

- (void)onClickPlayButton {
    NSString *path;

//    path = @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear0/prog_index.m3u8";
//    path = @"http://media.detu.com/@/17717910-8057-4FDF-2F33-F8B1F68282395/2016-08-22/57baeda5920ea-similar.mp4";
//    path = @"http://media.qicdn.detu.com/@/70955075-5571-986D-9DC4-450F13866573/2016-05-19/573d15dfa19f3-2048x1024.m3u8";
//    path =  [[NSBundle mainBundle] pathForResource:@"1123" ofType:@"png"];
//    path = @"http://yeelen.oss-cn-shenzhen.aliyuncs.com/7/500E70B410540307/20180613/20180613142856.m3u8";
//    path =  [[NSBundle mainBundle] pathForResource:@"184901AA" ofType:@"mp4"];
//    path = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
//    path = @"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8";
//    path = @"http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8";
//    path = @"http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8";
    path =  [[NSBundle mainBundle] pathForResource:@"184901AA" ofType:@"mp4"];
    
    decoder = [[LSPlayerMovieDecoder alloc] initWithMovie:path];
    decoder.delegate = self;
    
}

-(void)setCurrentTime:(float)currentTime{
    decoder.currentTime=currentTime;
}

-(float)currentTime{
    return decoder.currentTime;
}

-(float)duration{
    return decoder.duration;
}

- (void)movieDecoderDidFinishDecoding{
    
}

-(void)movieDecoderDidSeeked{
    
}

-(void)movieDecoderError:(NSError *)error;{
    
}
-(void)moviceDecoderPlayItemState:(MovieDecoderPlayItemState)state;{
    
}

-(void)movieDecoderDidDecodeFrameSDL:(SDL_VoutOverlay*)frame{

    AVFrameData *frameData = [self createFrameData:frame trimPadding:YES];
//    int height = frame->h;
//    int width = frame->w;
//    char *yuvData = malloc(width*height*1.5);
//    memcpy(yuvData, frameData.data0, width*height);
//    memcpy(yuvData+width*height, frameData.data1, width*height/4);
//    memcpy(yuvData+width*height*5/4, frameData.data2, width*height/4);
//
//    unsigned char *pBGR24 = malloc(frame->w*frame->h*3);
//    YV12ToBGR24_FFmpeg(yuvData, pBGR24, width, height);
//    free(yuvData);
    
//    YV12ToBGR24_Native(frameData.data0, frameData.data0, frameData.data0, pBGR24, frame->w, frame->h);

    dispatch_async(dispatch_get_main_queue(), ^{
//        openvcImageView.image = [opencvhandle cvInter:pBGR24 width:frame->w heigth:frame->h];
//        openvcImageView.image = [opencvhandle element:pBGR24 width:frame->w heigth:frame->h];
//        [_panoplayer displayYUV420pDatas:[sphere change:frame->pixels[0]] width:frame->w height:frame->h];
        [_panoplayer displayYUV420pData:frameData width:frame->w height:frame->h];
//        free(pBGR24);
        
        // 录制视频 有bug
//        if (!encoderManager) {
//            encoderManager = [[LSMP4EncoderManager alloc] init];
//            encoderManager.width = frame->w;
//            encoderManager.heigth = frame->h;
//            [encoderManager createMP4File:nil];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [encoderManager closeMP4File];
//            });
//        }
//        [encoderManager writeH264Data:frame->sourcePacket->data size:frame->sourcePacket->size];
        
        [self updateTime];
//        free(pBGR24);
    });
    

}

bool YV12ToBGR24_FFmpeg(unsigned char* pYUV,unsigned char* pBGR24,int width,int height)
{
    if (width < 1 || height < 1 || pYUV == NULL || pBGR24 == NULL)
        return false;
    AVPicture pFrameYUV,pFrameBGR;
    avpicture_fill(&pFrameYUV,pYUV,AV_PIX_FMT_YUV420P,width,height);
    
    //U,V互换
    uint8_t * ptmp=pFrameYUV.data[1];
    pFrameYUV.data[1]=pFrameYUV.data[2];
    pFrameYUV.data [2]=ptmp;
    
    avpicture_fill(&pFrameBGR,pBGR24,AV_PIX_FMT_BGR24,width,height);
    
    struct SwsContext* imgCtx = NULL;
    imgCtx = sws_getContext(width,height,AV_PIX_FMT_YUV420P,width,height,AV_PIX_FMT_BGR24,SWS_BILINEAR,0,0,0);
    
    if (imgCtx != NULL){
        sws_scale(imgCtx,pFrameYUV.data,pFrameYUV.linesize,0,height,pFrameBGR.data,pFrameBGR.linesize);
        if(imgCtx){
            sws_freeContext(imgCtx);
            imgCtx = NULL;
        }
        return true;
    }
    else{
        sws_freeContext(imgCtx);
        imgCtx = NULL;
        return false;
    }
}

- (void)updateTime{
    NSTimeInterval duration = decoder.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        
        durationTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
    } else {
        durationTimeLabel.text = @"--:--";
    }
    NSTimeInterval positon = decoder.currentTime;
    NSInteger intPosition = positon + 0.5;
    if (intDuration > 0) {
        progressSlider.value = positon;
    } else {
        progressSlider.value = 0.0f;
    }
    currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    

}

- (void)recordMp4{
    
}



bool YV12ToBGR24_Native(unsigned char* pY,unsigned char* pU,unsigned char* pV,unsigned char* pBGR24,int width,int height)
{
    if (width < 1 || height < 1 || pY == NULL || pBGR24 == NULL)
        return false;
//    const long len = width * height;
//    unsigned char* yData = pYUV;
//    unsigned char* vData = &yData[len];
//    unsigned char* uData = &vData[len >> 2];
    unsigned char* yData = pY;
    unsigned char* vData = pU;
    unsigned char* uData = pV;

    
    int bgr[3];
    int yIdx,uIdx,vIdx,idx;
    for (int i = 0;i < height;i++){
        for (int j = 0;j < width;j++){
            yIdx = i * width + j;
//            vIdx = (i/2) * (width/2) + (j/2);
            vIdx = (i*width+j)/2;
            uIdx = vIdx;
            
            bgr[0] = (int)(yData[yIdx] + 1.732446 * (uData[vIdx] - 128));                                    // b分量
            bgr[1] = (int)(yData[yIdx] - 0.698001 * (uData[uIdx] - 128) - 0.703125 * (vData[vIdx] - 128));    // g分量
            bgr[2] = (int)(yData[yIdx] + 1.370705 * (vData[uIdx] - 128));                                    // r分量
            
            for (int k = 0;k < 3;k++){
                idx = (i * width + j) * 3 + k;
                if(bgr[k] >= 0 && bgr[k] <= 255)
                    pBGR24[idx] = bgr[k];
                else
                    pBGR24[idx] = (bgr[k] < 0)?0:255;
            }
        }
    }
    return true;
    
}


//- (void)swithrgbData:(unsigned char *)pBGR heigth:(int)height width:(int)width{
//    // write out new image format.
//    int midy = height / 2;
//    int midx = width / 2;
//    int maxmag = (midy > midx ? midy : midx);
//    int circum = 2 * M_PI * maxmag;     // c = 2*pi*r
//    printf("P6\n");
//    printf("%d %d\n", circum, maxmag);
//    unsigned char *yData = pBGR;
//
//    unsigned char *pBGR24 = malloc(maxmag*circum);
//
//    char black[3] = {0,0,0};
//    int idx;
//    for (int y = 0; y < maxmag; y++) {
//        for (int x = 0; x < circum; x++) {
//            double theta = -1.0 * x / maxmag;       // -(x * 2.0 * M_PI / width);
//            double mag = maxmag - y;                // y * 1.0 * maxmag / height;
//            int targety = lrint(midy + mag * cos(theta));
//            int targetx = lrint(midx + mag * sin(theta));
//            if (targety < 0 || targety >= height || targetx < 0 || targetx >= width) {
//
//            for (int k = 0;k < 3;k++){
//                idx = (y * circum + x) * 3 + k;
//                pBGR24[idx] = yData[targety];
////                if(bgr[k] >= 0 && bgr[k] <= 255)
////                    pBGR24[idx] = bgr[k];
////                else
////                    pBGR24[idx] = (bgr[k] < 0)?0:255;
//            }
//
//            } else {
////                fwrite(&pixels[targety][targetx * 3], 1, 3, stdout);
//            }
//        }
//    }
//
//}

- (AVFrameData *) createFrameData: (SDL_VoutOverlay*) frame
                     trimPadding: (BOOL) trim{

    AVFrameData *frameData = [[AVFrameData alloc] init];
    if (!frame->pixels[0]) {
        return frameData;
    }
    frameData.width = [[NSNumber alloc] initWithInt:frame->w];
    frameData.height = [[NSNumber alloc] initWithInt:frame->h];
    frameData.colorPlane0 = [[NSMutableData alloc] init];
    frameData.colorPlane1 = [[NSMutableData alloc] init];
    frameData.colorPlane2 = [[NSMutableData alloc] init];
    
    [frameData.colorPlane0 appendBytes:frame->pixels[0] length:frame->w];
    [frameData.colorPlane1 appendBytes:frame->pixels[0] length:frame->w/2];
    [frameData.colorPlane2 appendBytes:frame->pixels[0] length:frame->w/2];
    frameData.data0 = frame->pixels[0];
    frameData.data1 = frame->pixels[1];
    frameData.data2 = frame->pixels[2];

    frameData.lineSize0 = [[NSNumber alloc] initWithInt:frame->w];
    frameData.lineSize1 = [[NSNumber alloc] initWithInt:frame->w/2];
    frameData.lineSize2 = [[NSNumber alloc] initWithInt:frame->w/2];


    return frameData;

}


@end
