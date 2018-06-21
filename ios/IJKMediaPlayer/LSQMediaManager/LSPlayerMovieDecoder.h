//
//  LSPlayerMoviewDecoder.h
//  IJKMediaFramework
//
//  Created by 赖双全 on 2018/6/8.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ijksdl.h"

typedef enum {
    MOVICE_STATE_PLAYING,
    MOVICE_STATE_STOP,
    MOVICE_STATE_PAUSE,
    MOVICE_STATE_BUFFER_EMPTY,
    MOVICE_STATE_START_SEEK,
    MOVICE_STATE_FAILED,
    MOVICE_STATE_READYTOPALY,
    MOVICE_STATE_UNKNOWN
    
}MovieDecoderPlayItemState;

@protocol MovieDecoderDelegate <NSObject>

@required

-(void)movieDecoderDidFinishDecoding;
-(void)movieDecoderDidSeeked;
-(void)movieDecoderError:(NSError *)error;
-(void)moviceDecoderPlayItemState:(MovieDecoderPlayItemState)state;
-(void)movieDecoderDidDecodeFrameSDL:(SDL_VoutOverlay*)frame;

@optional
-(void)movieDecoderDidDecodeFrame:(CVPixelBufferRef)buffer;
-(void)movieDecoderDidDecodeFrameBuffer:(void*)buffer width:(int)width height:(int)height channel:(int)channel;
-(void)movieDecoderDidDecodeFrameRawbuf:(uint8_t*)frame:(int)w:(int)h;
-(void)movieDecoderOnStatisticsUpdated:(NSDictionary*)dic;

@end

@interface LSPlayerMovieDecoder : NSObject
@property (nonatomic,readonly)   float duration;
@property (nonatomic,assign)   double currentTime;

@property (nonatomic,weak)   id<MovieDecoderDelegate> delegate;
-(id)initWithMovie:(NSString*)path;
-(void)start;
-(void)pause;
-(void)stop;
-(void)cleargc;

@end
