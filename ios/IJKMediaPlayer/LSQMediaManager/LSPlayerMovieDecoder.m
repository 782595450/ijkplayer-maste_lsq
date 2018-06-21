


//
//  LSPlayerMoviewDecoder.m
//  IJKMediaFramework
//
//  Created by 赖双全 on 2018/6/8.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "LSPlayerMovieDecoder.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface LSPlayerMovieDecoder ()
{
    NSRecursiveLock *_lock;
    void *_framedata;
    int _videoWidth;
    int _videoHeight;
    int _channel;
    IJKFFMoviePlayerController *_player;
}

@end

@implementation LSPlayerMovieDecoder

-(id)initWithMovie:(NSString*)path{
    self = [super init];
    if (self) {
        _lock = [[NSRecursiveLock alloc] init];
        [self loadMovie:path];
    }
    
    return self;
}

-(BOOL)loadMovie:(NSString*)path
{
    
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
    //  [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
    
    IJKFFOptions *options =  [[IJKFFOptions alloc] init];
//    [options setPlayerOptionIntValue:0 forKey:@"packet-buffering"];
//    [options setPlayerOptionIntValue:30  forKey:@"max-fps"];
//    [options setPlayerOptionIntValue:1  forKey:@"framedrop"];
//    [options setPlayerOptionIntValue:0  forKey:@"start-on-prepared"];
//    [options setPlayerOptionIntValue:0  forKey:@"http-detect-range-support"];
//    [options setPlayerOptionIntValue:48  forKey:@"skip_loop_filter"];
//    [options setPlayerOptionIntValue:0  forKey:@"packet-buffering"];
//    [options setPlayerOptionIntValue:2000000 forKey:@"analyzeduration"];
//    [options setPlayerOptionIntValue:25  forKey:@"min-frames"];
//    [options setPlayerOptionIntValue:1  forKey:@"start-on-prepared"];
//
//    [options setCodecOptionIntValue:8 forKey:@"skip_frame"];
//
//    [options setFormatOptionValue:@"nobuffer" forKey:@"fflags"];
//    [options setFormatOptionValue:@"8192" forKey:@"probsize"];
//    [options setFormatOptionIntValue:0 forKey:@"auto_convert"];
//    [options setFormatOptionIntValue:1 forKey:@"reconnect"];
//
//    [options setPlayerOptionIntValue:0  forKey:@"videotoolbox"];
//
//    // 帧速率(fps) （可以改，确认非标准桢率会导致音画不同步，所以只能设定为15或者29.97）
//    [options setPlayerOptionIntValue:29.97 forKey:@"r"];
//    // -vol——设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推
//    [options setPlayerOptionIntValue:512 forKey:@"vol"];
//    [options setPlayerOptionValue:@"fcc-_es2" forKey:@"overlay-format"];
    //disable audio
    //[options setPlayerOptionIntValue:1 forKey:@"an"];
    [options setPlayerOptionValue:@"fcc-i420"          forKey:@"overlay-format"];


    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:path] withOptions:options];
    
    __weak typeof(self) weak = self;
    _player.displayFrameBlock = ^(SDL_VoutOverlay* overlay){
        __strong typeof(weak) self = weak;
        if (overlay == NULL) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(movieDecoderDidDecodeFrameSDL:)]) {
            // 传出每一帧数据
            [self.delegate movieDecoderDidDecodeFrameSDL:overlay];
        }
        
    };
    
    [_player prepareToPlay];
    [self start];
    return TRUE;
}
// 开始解码
-(void)start{
    [_player play];
    [self installMovieNotificationObservers];
    
}

// 暂停播放
-(void)pause{
    [_player pause];
}

// 停止播放
-(void)stop{
    [_player stop];
    [self removeMovieNotificationObservers];
}

// 清空数据
-(void)cleargc{
    NSLog(@"alc cleargc");
    [_lock lock];
    if (_player != nil) {
        [_player shutdown];
    }
    _player = nil;
    [_lock unlock];
    
}

-(float)duration{
    return _player.duration;
}

-(double)currentTime{
    return _player.currentPlaybackTime ;
}

// 拖动进度条设置播放时间
-(void)setCurrentTime:(double)currentTime{
    [_lock lock];
    [_player setCurrentPlaybackTime:currentTime];
    [self.delegate movieDecoderDidSeeked];
    [_lock unlock];
}

-(void)dealloc{
    NSLog(@"LSPlayerMovie dealloc");
    [self cleargc];
    
}


#pragma mark - notification
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    MPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & MPMovieLoadStatePlaythroughOK) != 0) {
        [self.delegate moviceDecoderPlayItemState:MOVICE_STATE_PLAYING];
        NSLog(@"loadStateDidChange: MPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & MPMovieLoadStateStalled) != 0) {
        //加载中
        [self.delegate moviceDecoderPlayItemState:MOVICE_STATE_BUFFER_EMPTY];
        NSLog(@"loadStateDidChange: MPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
    
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case MPMovieFinishReasonPlaybackEnded:
            [self.delegate movieDecoderDidFinishDecoding];
            NSLog(@"playbackStateDidChange: MPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case MPMovieFinishReasonUserExited:
            [self.delegate movieDecoderError:[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:@{NSLocalizedDescriptionKey:@"播放失败，用户强制退出"}]];
            NSLog(@"playbackStateDidChange: MPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case MPMovieFinishReasonPlaybackError:
            [self.delegate movieDecoderError:[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:@{NSLocalizedDescriptionKey:@"播放文件格式错误或网络异常"}]];
            
            NSLog(@"playbackStateDidChange: MPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            [self.delegate movieDecoderError:[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:@{NSLocalizedDescriptionKey:@"未知错误"}]];
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case MPMoviePlaybackStateStopped: {
            [self.delegate moviceDecoderPlayItemState:MOVICE_STATE_STOP];
            NSLog(@"moviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStatePlaying: {
            [self.delegate moviceDecoderPlayItemState:MOVICE_STATE_PLAYING];
            NSLog(@"moviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStatePaused: {
            [self.delegate moviceDecoderPlayItemState:MOVICE_STATE_PAUSE];
            NSLog(@"moviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStateInterrupted: {
            NSLog(@"moviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward: {
            NSLog(@"moviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"moviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

//- (void)mediaPlayOnStatisticsInfoUpdated:(NSNotification*)notification {
//    NSDictionary* dic = notification.userInfo;
//    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(movieDecoderOnStatisticsUpdated:)]) {
//        [self.delegate movieDecoderOnStatisticsUpdated:dic];
//    }
//}

#pragma mark Install Movie Notifications
// 注册通知
-(void)installMovieNotificationObservers
{
    
    [self removeMovieNotificationObservers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    // 自定义统计数据
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(mediaPlayOnStatisticsInfoUpdated:)
//                                                 name:IJKMPMoviePlayerDetuStatisticsNotification
//                                               object:_player];
}

// 删除通知
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerDetuStatisticsNotification object:_player];
}

    
@end
