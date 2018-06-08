#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "AVFrameData.h"


@interface WFViewController : GLKViewController{
    int m_nWidth;
    int m_nHeight;
    
    Byte* yData;
    Byte* uData;
    Byte* vData;

    NSCondition *m_YUVDataLock;
    GLuint _testTxture[3];
    BOOL m_bNeedSleep;
}

- (void) WriteYUVFrame: (AVFrameData *) frameData;

@end
