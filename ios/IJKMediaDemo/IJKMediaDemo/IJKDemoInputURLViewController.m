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
#define LSScreenWidth  [UIScreen mainScreen].bounds.size.width
#define LSScreenHeight [UIScreen mainScreen].bounds.size.height

@interface IJKDemoInputURLViewController () <UITextViewDelegate,MovieDecoderDelegate>{
    LSPlayerMovieDecoder* decoder;
    OpenGLView20 *_panoplayer;
    unsigned char* m_pBuffer;

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
    _panoplayer = [[OpenGLView20 alloc] init];
    _panoplayer.backgroundColor = [UIColor blueColor];
    _panoplayer.frame = CGRectMake(0, 44, LSScreenWidth, LSScreenHeight);
//    NSLog(@" frame size %f,%f",_panoplayer.frame.size.width,_panoplayer.frame.size.height);
    [self.view addSubview:_panoplayer];

}

- (void)onClickPlayButton {
    NSString *path;

//    path = @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/gear0/prog_index.m3u8";
//    path = @"http://media.detu.com/@/17717910-8057-4FDF-2F33-F8B1F68282395/2016-08-22/57baeda5920ea-similar.mp4";
//    path = @"http://media.qicdn.detu.com/@/70955075-5571-986D-9DC4-450F13866573/2016-05-19/573d15dfa19f3-2048x1024.m3u8";
//    path =  [[NSBundle mainBundle] pathForResource:@"IMG_4075" ofType:@"MP4"];
    path = @"http://storage.yeelens.com/vod/video_audio/vod.m3u8";
    
    decoder = [[LSPlayerMovieDecoder alloc] initWithMovie:path];
    decoder.delegate = self;
    
}

-(void)movieDecoderDidFinishDecoding{
    
}

-(void)movieDecoderDidSeeked{
    
}

-(void)movieDecoderError:(NSError *)error;{
    
}
-(void)moviceDecoderPlayItemState:(MovieDecoderPlayItemState)state;{
    
}

-(void)movieDecoderDidDecodeFrameSDL:(SDL_VoutOverlay*)frame;{

    AVFrameData *frameData = [self createFrameData:frame trimPadding:YES];
//    [_panoplayer WriteYUVFrame:frameData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_panoplayer displayYUV420pData:frameData width:frame->w height:frame->h];
    });
    
}


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
