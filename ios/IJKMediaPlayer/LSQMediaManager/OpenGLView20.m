//
//  OpenGLView.m
//  MyTest
//
//  Created by smy on 12/20/11.
//  Copyright (c) 2011 ZY.SYM. All rights reserved.
//


#import "OpenGLView20.h"
//#import "CStreamItem.h"

enum AttribEnum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXTURE,
    ATTRIB_COLOR,
};

enum TextureType
{
    TEXY = 0,
    TEXU,
    TEXV,
    TEXC
};

//#define PRINT_CALL 1

@interface OpenGLView20()

/** 
 初始化YUV纹理
 */
- (void)setupYUVTexture;

/** 
 创建缓冲区
 @return 成功返回TRUE 失败返回FALSE
 */
- (BOOL)createFrameAndRenderBuffer;

/** 
 销毁缓冲区
 */
- (void)destoryFrameAndRenderBuffer;

//加载着色器
/** 
 初始化YUV纹理
 */
- (void)loadShader;

/** 
 编译着色代码
 @param shader        代码
 @param shaderType    类型
 @return 成功返回着色器 失败返回－1
 */
- (GLuint)compileShader:(NSString*)shaderCode withType:(GLenum)shaderType;

/** 
 渲染
 */
- (void)render;
@end

@implementation OpenGLView20

//- (void)debugGlError
//{
//    GLenum r = glGetError();
//    if (r != 0)
//    {
//        printf("%d   \n", r);
//    }
//}
- (BOOL)doInit
{
    pthread_mutex_init(&yuvMut, NULL);
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
                                    nil];
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    _viewScale = [UIScreen mainScreen].scale;
    
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(!_glContext || ![EAGLContext setCurrentContext:_glContext])
    {
        return NO;
    }
	
    [self setupYUVTexture];
    [self loadShader];
    glUseProgram(_program);
    
    GLuint textureUniformY = glGetUniformLocation(_program, "SamplerY");
    GLuint textureUniformU = glGetUniformLocation(_program, "SamplerU");
    GLuint textureUniformV = glGetUniformLocation(_program, "SamplerV");
    glUniform1i(textureUniformY, 0);
    glUniform1i(textureUniformU, 1);
    glUniform1i(textureUniformV, 2);
    
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        if (![self doInit])
        {
            self = nil;
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (![self doInit])
        {
            self = nil;
        }
    }
    return self;
}

- (void)layoutSubviews
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self)
        {
            [EAGLContext setCurrentContext:_glContext];
            [self destoryFrameAndRenderBuffer];
            [self createFrameAndRenderBuffer];
        }

//        glViewport(1, 1, self.bounds.size.width*_viewScale - 2, self.bounds.size.height*_viewScale - 2);
//    });
}

- (void)setupYUVTexture
{
    if (_textureYUV[TEXY])
    {
        glDeleteTextures(3, _textureYUV);
    }
    glGenTextures(3, _textureYUV);
    if (!_textureYUV[TEXY] || !_textureYUV[TEXU] || !_textureYUV[TEXV])
    {
        NSLog(@"<<<<<<<<<<<<纹理创建失败!>>>>>>>>>>>>");
        return;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXY]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXU]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXV]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)render;
{
//    [EAGLContext setCurrentContext:_glContext];
    CGSize size = self.bounds.size;
    glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
    

    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };


    static const GLfloat coordVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    // Update attribute values
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);


    glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, coordVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTURE);

    // Draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - 设置openGL
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (BOOL)createFrameAndRenderBuffer
{
    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    if (![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
    {
        NSLog(@"attach渲染缓冲区失败");
    }
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    return YES;
}

- (void)destoryFrameAndRenderBuffer
{
    if (_framebuffer)
    {
        glDeleteFramebuffers(1, &_framebuffer);
    }
    
    if (_renderBuffer)
    {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    
    _framebuffer = 0;
    _renderBuffer = 0;
}

#define FSH @"varying lowp vec2 TexCoordOut;\
\
uniform sampler2D SamplerY;\
uniform sampler2D SamplerU;\
uniform sampler2D SamplerV;\
\
void main(void)\
{\
    mediump vec3 yuv;\
    lowp vec3 rgb;\
    \
    yuv.x = texture2D(SamplerY, TexCoordOut).r;\
    yuv.y = texture2D(SamplerU, TexCoordOut).r - 0.5;\
    yuv.z = texture2D(SamplerV, TexCoordOut).r - 0.5;\
    \
    rgb = mat3( 1,       1,         1,\
               0,       -0.39465,  2.03211,\
               1.13983, -0.58060,  0) * yuv;\
    \
    gl_FragColor = vec4(rgb, 1);\
    \
}"

#define VSH @"attribute vec4 position;\
attribute vec2 TexCoordIn;\
varying vec2 TexCoordOut;\
\
void main(void)\
{\
    gl_Position = position;\
    TexCoordOut = TexCoordIn;\
}"

/** 
 加载着色器
 */
- (void)loadShader
{
	/** 
	 1
	 */
    GLuint vertexShader = [self compileShader:VSH withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:FSH withType:GL_FRAGMENT_SHADER];
    
	/** 
	 2
	 */
    _program = glCreateProgram();
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    
	/** 
	 绑定需要在link之前
	 */
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_TEXTURE, "TexCoordIn");
    
    glLinkProgram(_program);
    
	/** 
	 3
	 */
    GLint linkSuccess;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"<<<<着色器连接失败 %@>>>", messageString);
        //exit(1);
    }
    
    if (vertexShader)
		glDeleteShader(vertexShader);
    if (fragmentShader)
		glDeleteShader(fragmentShader);
}

- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType
{
    
   	/** 
	 1
	 */
    NSError *error;
    
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    else
    {
        //NSLog(@"shader code-->%@", shaderString);
    }
    
	/** 
	 2
	 */
    GLuint shaderHandle = glCreateShader(shaderType);    
    
	/** 
	 3
	 */
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
	/** 
	 4
	 */
    glCompileShader(shaderHandle);
    
	/** 
	 5
	 */
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}
- (int)strend:(unsigned char *)data {
    int i = 0;
    if (data == 0) {
        return 0;
    }
    while (data[i] != '\0') {
        i++;
    }
    return i;
}

- (void)drawData:(YUVModel *)model {
    
//    int i = [self strend:model.yuvData];
//    NSLog(@"长度 - %d",i);
    
//    char * a = (char*)malloc(sizeof(model.yuvData)*16);
//    NSData *data = [NSData dataWithBytes:a length:strlen(a)];
//    NSLog(@"11 - %d",data.bytes);
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXY]);
    
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, model.width, model.height, GL_RED_EXT, GL_UNSIGNED_BYTE, model.yuvData);
    
    //[self debugGlError];
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXU]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, model.width/2, model.height/2, GL_RED_EXT, GL_UNSIGNED_BYTE, model.yuvData + model.width * model.height);
    
    // [self debugGlError];
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXV]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, model.width/2, model.height/2, GL_RED_EXT, GL_UNSIGNED_BYTE, model.yuvData + model.width * model.height * 5 / 4);
    
    //[self debugGlError];
    
    //显示的形状
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat coordVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    // Update attribute values
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    
    glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, coordVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTURE);
    
    // Draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - 接口
- (void)displayYUV420pData:(AVFrameData *)data width:(GLint)w height:(GLint)h;
{
    //_pYuvData = data;
    //    MyLog(@"width:%d, height:%d", w, h);
    if (!self.window)
    {
        return;
    }
    @synchronized(self)
    {
        if (w != _videoW || h != _videoH)
        {
            [self setVideoSize:w height:h];
        }
        [EAGLContext setCurrentContext:_glContext];
        
        glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXY]);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RED_EXT, GL_UNSIGNED_BYTE, data.data0);
        
        //[self debugGlError];
        
        glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXU]);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w/2, h/2, GL_RED_EXT, GL_UNSIGNED_BYTE, data.data1);
        
        // [self debugGlError];
        
        glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXV]);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w/2, h/2, GL_RED_EXT, GL_UNSIGNED_BYTE, data.data2);
        
        //[self debugGlError];
        
        [self render];
    }
    
#ifdef DEBUG
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
    {
        printf("GL_ERROR=======>%d\n", err);
    }
    struct timeval nowtime;
    gettimeofday(&nowtime, NULL);
    if (nowtime.tv_sec != _time.tv_sec)
    {
        printf("视频 %ld 帧率:   %ld\n", (long)self.tag, (long)_frameRate);
        memcpy(&_time, &nowtime, sizeof(struct timeval));
        _frameRate = 1;
    }
    else
    {
        _frameRate++;
    }
#endif
}
- (int)myStrlen:(unsigned char *)str {
    int i = -1;
    while(i++,'\0' != str[i]);
    return i;
}

// 4分格渲染
- (void)displayYUV420p4MultilatticeData:(NSArray *)data SelectIndex:(int)index isFull:(BOOL)isFull{
    if (!self.window){
        return;
    }

    pthread_mutex_lock(&yuvMut);
    glClearColor(0.0, 0.0, 0.0, 0.1);
    glClear(GL_COLOR_BUFFER_BIT);
    // 是否全屏
    if (isFull) {
        YUVModel *model = data[index];
        CGSize size = self.bounds.size;
        if (model.yuvData) {
            [self setVideoSize:model.width height:model.height];
            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
            [self drawData:model];
            glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
            [_glContext presentRenderbuffer:GL_RENDERBUFFER];
            
        }
        pthread_mutex_unlock(&yuvMut);
        return;
    }

    for (int i = 0; i < 2; i ++) {
        for (int y = 0; y < 2; y ++) {
            float w_Textures = self.bounds.size.width;
            float h_Textures = self.bounds.size.height;
            YUVModel *model = data[y + (i * 2)];
            if (model.yuvData != NULL) {
                [self setVideoSize:model.width height:model.height];
                int tag = y + (i * 2);
                if (tag == 0) {
                    glViewport(0, h_Textures*_viewScale/2.0 , w_Textures*_viewScale/2.0, h_Textures*_viewScale/2.0 );
                }else if (tag == 1){
                    glViewport(w_Textures*_viewScale / 2, h_Textures*_viewScale / 2, w_Textures*_viewScale/2.0, h_Textures*_viewScale/2.0);
                } else if ( tag == 2){
                    glViewport(0, 0, w_Textures*_viewScale/2.0 ,h_Textures*_viewScale/2.0);
                }else if ( tag == 3){
                    glViewport(w_Textures*_viewScale / 2, 0, w_Textures*_viewScale/2.0 ,h_Textures*_viewScale/2.0);
                }
                [self drawData:model];
            }
            
        }
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    pthread_mutex_unlock(&yuvMut);
}

// 8分格渲染
- (void)displayYUV420p8MultilatticeData:(NSArray *)data SelectIndex:(int)index isFull:(BOOL)isFull{
    if (!self.window){
        return;
    }
    
    pthread_mutex_lock(&yuvMut);
    glClearColor(0.0, 0.0, 0.0, 0.1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGSize size = self.bounds.size;

    // 是否全屏
    if (isFull) {
        YUVModel *model = data[index];
        if (model.yuvData) {
            [self setVideoSize:model.width height:model.height];
            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
            [self drawData:model];
            glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
            [_glContext presentRenderbuffer:GL_RENDERBUFFER];

        }
        pthread_mutex_unlock(&yuvMut);
        return;
    }
    for (int i = 0; i < 4; i ++) {
        for (int y = 0; y < 2; y ++) {
            YUVModel *model = data[y + (i * 2)];
            if (model.yuvData != NULL) {
                [self setVideoSize:model.width height:model.height];
                int tag = y + (i * 2);
                if (tag == 0) {
                    glViewport(1, size.height*_viewScale / 4 * 3 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if (tag == 1){
                    glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 4 * 3 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                } else if ( tag == 2){
                    glViewport(1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if ( tag == 3){
                    glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if ( tag == 4){
                    glViewport(1, size.height*_viewScale / 4  - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if ( tag == 5){
                    glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 4 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if ( tag == 6){
                    glViewport(1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }else if ( tag == 7){
                    glViewport(size.width*_viewScale / 2 - 1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                }
                [self drawData:model];
            }
            
        }
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    
    pthread_mutex_unlock(&yuvMut);
}

- (void)displayYUV420pData:(NSArray *)data SelectIndex:(int)index IsFull:(BOOL)isFull Type:(int)type;
{
//
    //_pYuvData = data;
//    MyLog(@"width:%d, height:%d", w, h);
    if (!self.window)
    {
        return;
    }
   
    @synchronized(self)
    {
//        [self clearFrame];
        glClearColor(0.0, 0.0, 0.0, 0.1);
        glClear(GL_COLOR_BUFFER_BIT);
//
        
        
        for (int i = 0; i <= data.count - 1; i++) {
            
            if (isFull) {
                if (i != index - 1) {
                    continue;
                }
            }
            YUVModel *model = data[i];
            
            if (model.width != 0 || model.height != 0 )
            {
                [self setVideoSize:model.width height:model.height];
            }
            
            CGSize size = self.bounds.size;
            if (isFull) {
                model.listIndex = 100;
            }
//            int i = [self myStrlen:model.yuvData];
//            NSLog(@"长度 - %d",i);
            if (type == 0) {
                if (data.count == 4) {
                    switch (model.listIndex) {
                        case 1: case 5:
                        {
                            
                            glViewport(1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 2: case 6:{
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 3: case 7:{
                            glViewport(1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 4: case 8:  {
                            glViewport(size.width*_viewScale / 2 - 1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                            //放大
                        case 100: {
                            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
                            [self drawData:model];
                        }
                            break;
                        default: {
                            continue;
                        }
                            break;
                    }
                } else if (data.count == 8) {
                    
                    switch (model.listIndex) {
                        case 1: case 9:
                        {
                            glViewport(1, size.height*_viewScale / 4 * 3 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 2: case 10:{
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 4 * 3 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 3: case 11: {
                            glViewport(1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 4: case 12: {
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 5: case 13:
                        {
                            glViewport(1, size.height*_viewScale / 4  - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 6: case 14:{
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 4 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 7: case 15: {
                            glViewport(1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 8: case 16: {
                            glViewport(size.width*_viewScale / 2 - 1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 4 - 2);
                            [self drawData:model];
                        }
                            break;
                            //放大
                        case 100: {
                            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
                            [self drawData:model];
                        }
                            break;
                        default: {
                            continue;
                        }
                            break;
                    }
                }
                //横向啊
            } else if (type == 1) {
                if (data.count == 4) {
                    switch (model.listIndex) {
                        case 1: case 5:
                        {
                            glViewport(1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 2: case 6:{
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 3: case 7:{
                            glViewport(1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 4: case 8:  {
                            glViewport(size.width*_viewScale / 2 - 1, 1, (size.width*_viewScale) / 2 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                            //放大
                        case 100: {
                            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
                            [self drawData:model];
                        }
                            break;
                        default: {
                            continue;
                        }
                            break;
                    }
                } else if (data.count == 8) {
                    
                    switch (model.listIndex) {
                        case 1: case 9:
                        {
                            glViewport(1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 2: case 10:{
                            glViewport(size.width*_viewScale / 4 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 3: case 11: {
                            glViewport(size.width*_viewScale / 2 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 4: case 12: {
                            glViewport(size.width*_viewScale / 4 * 3 - 1, size.height*_viewScale / 2 - 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 5: case 13:
                        {
                            glViewport(1, 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 6: case 14:{
                            glViewport(size.width*_viewScale / 4 - 1, 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 7: case 15: {
                            glViewport(size.width*_viewScale / 2 - 1, 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                        case 8: case 16: {
                            glViewport(size.width*_viewScale / 4 * 3 - 1, 1, (size.width*_viewScale) / 4 - 2, (size.height*_viewScale) / 2 - 2);
                            [self drawData:model];
                        }
                            break;
                            //放大
                        case 100: {
                            glViewport(1, 1, size.width*_viewScale-2, size.height*_viewScale-2);
                            [self drawData:model];
                        }
                            break;
                        default: {
                            continue;
                        }
                            break;
                    }
                }
            }
            
        }
        //渲染画面
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}
    
    
#ifdef DEBUG
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
    {
        printf("GL_ERROR=======>%d\n", err);
    }
    struct timeval nowtime;
    gettimeofday(&nowtime, NULL);
    if (nowtime.tv_sec != _time.tv_sec)
    {
        printf("视频 %ld 帧率:   %ld\n", (long)self.tag, (long)_frameRate);
        memcpy(&_time, &nowtime, sizeof(struct timeval));
        _frameRate = 1;
    }
    else
    {
        _frameRate++;
    }
#endif
}

- (void)setVideoSize:(GLuint)width height:(GLuint)height
{
    
    _videoW = width;
    _videoH = height;
    
    void *blackData = malloc(width * height * 1.5);
	if(blackData)
		//bzero(blackData, width * height * 1.5);
        memset(blackData, 0x0, width * height * 1.5);
    
    [EAGLContext setCurrentContext:_glContext];
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXY]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width, height, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData);
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXU]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width/2, height/2, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + width * height);
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXV]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width/2, height/2, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + width * height * 5 / 4);
    free(blackData);
}


- (void)clearFrame
{
    pthread_mutex_destroy(&yuvMut);
    if ([self window])
    {
        [EAGLContext setCurrentContext:_glContext];
        glClearColor(0.0, 0.0, 0.0, 0.1);
        glClear(GL_COLOR_BUFFER_BIT);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
}

@end
