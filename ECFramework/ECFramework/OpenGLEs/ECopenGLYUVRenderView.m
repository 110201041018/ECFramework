//
//  ECopenGLView.m
//  ECFramework
//
//  Created by Ezio on 2019/4/28.
//  Copyright © 2019 EzioChen. All rights reserved.
//

#import "ECopenGLYUVRenderView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#include <sys/time.h>

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

enum AttribEnum{
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

@interface ECopenGLYUVRenderView(){
    /**
     OpenGL绘图上下文
     */
    EAGLContext             *glContext;
    /**
     帧缓冲区
     */
    GLuint                  framebuffer;
    /**
     渲染缓冲区
     */
    GLuint                  renderBuffer;
    /**
     着色器句柄
     */
    GLuint                  program;
    /**
     YUV纹理数组
     */
    GLuint                  textureYUV[3];
    /**
     视频宽度
     */
    GLuint                  videoW;
    /**
     视频高度
     */
    GLuint                  videoH;
    GLsizei                 viewScale;
#ifdef DEBUG
    struct timeval      time;
    NSInteger           frameRate;
#endif
}
@end

@implementation ECopenGLYUVRenderView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
- (void)layoutSubviews
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self)
        {
            [EAGLContext setCurrentContext:glContext];
            [self destoryFrameAndRenderBuffer];
            [self createFrameAndRenderBuffer];
        }
        
        glViewport(1, 1, self.bounds.size.width*viewScale - 2, self.bounds.size.height*viewScale - 2);
    });
}

-(instancetype)init{
    self = [super init];
    if (self) {
        if ([self initOpenGL]) {
            return self;
        }else{
            return NULL;
        }
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self initOpenGL]) {
            return self;
        }else{
            return NULL;
        }
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        if ([self initOpenGL]) {
            return self;
        }else{
            return NULL;
        }
    }
    return self;
}

-(BOOL)initOpenGL{
    //创建OpenGL context
    glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //启用计数器维护 context
    BOOL ret = [EAGLContext setCurrentContext:glContext];
    if (!glContext || !ret){
        NSLog(@"glcontext alloc init failed !");
        return NO;
    }
    //创建Layer配置
    CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
    eagLayer.opaque = YES;
    eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:NO],
                                   kEAGLDrawablePropertyRetainedBacking,
                                   kEAGLColorFormatRGB565,
                                   kEAGLDrawablePropertyColorFormat,
                                   nil];
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    viewScale = [UIScreen mainScreen].scale;
    //添加着色器 Shader
    [self addShader];
    
    //创建YUV texture
    [self setupYUVTexture];
    
    GLuint textureUniformY = glGetUniformLocation(program, "SamplerY");
    GLuint textureUniformU = glGetUniformLocation(program, "SamplerU");
    GLuint textureUniformV = glGetUniformLocation(program, "SamplerV");
    glUniform1i(textureUniformY, 0);
    glUniform1i(textureUniformU, 1);
    glUniform1i(textureUniformV, 2);
    
    return YES;
}

/**
 加载着色器
 */
-(void)addShader{
    //顶点着色器
    GLuint vertexShader = [self compileShader:VSH withType:GL_VERTEX_SHADER];
    //片段着色器
    GLuint fragmentShader = [self compileShader:FSH withType:GL_FRAGMENT_SHADER];

    //创建一个容纳程序的容器
    program = glCreateProgram();
    //将shader容器添加到程序中
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    //把program的顶点属性索引与顶点shader中的变量名进行绑定,绑定需要在link之前
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_TEXTURE, "TexCoordIn");
    //链接程序，创建可执行的OpenGL ES program
    glLinkProgram(program);
    
    GLint linkSuccess;
    //获取program对象的参数值
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"<<<<着色器连接失败 %@>>>", messageString);
        if (vertexShader)
            glDeleteShader(vertexShader);
        if (fragmentShader)
            glDeleteShader(fragmentShader);
        //exit(1);
    }

}

/**
 初始化着色器

 @param shaderString 着色器宏
 @param shaderType 着色器类型
 @return GLuint
 */
- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType{
    NSError *error = nil;
    if (!shaderString) {
        NSLog(@"loading shader error:%@",error.localizedDescription);
        exit(1);
    }
    //创建一个 shader 的 handle。
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    
    //当一个 Shader Object 被创建之后,初始为空的,里面没有内容,那么需要先把 GLSL 书写的内容输入到这个 Shader Object 中,那么这个 glShaderSource 的 API,就是往一个 shader 的 handle 中传递 shader source。
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //把一个已经包含 shader source 内容的 shader 发给 GPU 进行编译。
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    
    //glGetProgramInfoLog,glGetShaderInfoLog,glGetProgramiv,glGetShaderiv 用于获取 program 和 shader 的 log,以及其他参数信息,以及 glGet 这个用于获取 GPU 常规信息的 API
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

- (void)setupYUVTexture
{
    if (textureYUV[TEXY])
    {
        glDeleteTextures(3, textureYUV);
    }
    glGenTextures(3, textureYUV);
    if (!textureYUV[TEXY] || !textureYUV[TEXU] || !textureYUV[TEXV])
    {
        NSLog(@"<<<<<<<<<<<<纹理创建失败!>>>>>>>>>>>>");
        return;
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXY]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXU]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXV]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}


/**
 创建缓存区 render

 @return 状态
 */
- (BOOL)createFrameAndRenderBuffer
{
    glGenFramebuffers(1, &framebuffer);
    glGenRenderbuffers(1, &renderBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    
    if (![glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
    {
        NSLog(@"attach渲染缓冲区失败");
    }
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    return YES;
}

/**
 销毁缓冲器
 */
- (void)destoryFrameAndRenderBuffer
{
    if (framebuffer)
    {
        glDeleteFramebuffers(1, &framebuffer);
    }
    
    if (renderBuffer)
    {
        glDeleteRenderbuffers(1, &renderBuffer);
    }
    
    framebuffer = 0;
    renderBuffer = 0;
}

- (void)render
{
    [EAGLContext setCurrentContext:glContext];
    CGSize size = self.bounds.size;
    glViewport(1, 1, size.width*viewScale-2, size.height*viewScale-2);
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
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [glContext presentRenderbuffer:GL_RENDERBUFFER];
}


#pragma mark - 接口
- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h
{
    //_pYuvData = data;
    //    if (_offScreen || !self.window)
    //    {
    //        return;
    //    }
    @synchronized(self)
    {
        if (w != videoW || h != videoH)
        {
            [self setVideoSize:w height:h];
        }
        [EAGLContext setCurrentContext:glContext];
        
        glBindTexture(GL_TEXTURE_2D, textureYUV[TEXY]);
        
        //glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels);
        
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (int)w, (int)h, GL_RED_EXT, GL_UNSIGNED_BYTE, data);
        
        //[self debugGlError];
        
        glBindTexture(GL_TEXTURE_2D, textureYUV[TEXU]);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (int)w/2, (int)h/2, GL_RED_EXT, GL_UNSIGNED_BYTE, data + w * h);
        
        // [self debugGlError];
        
        glBindTexture(GL_TEXTURE_2D, textureYUV[TEXV]);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (int)w/2, (int)h/2, GL_RED_EXT, GL_UNSIGNED_BYTE, data + w * h * 5 / 4);
        
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
    if (nowtime.tv_sec != time.tv_sec)
    {
//        printf("视频 %d 帧率:   %d\n", self.tag, frameRate);
        memcpy(&time, &nowtime, sizeof(struct timeval));
        frameRate = 1;
    }
    else
    {
        frameRate++;
    }
#endif
}

- (void)setVideoSize:(NSInteger)width height:(NSInteger)height
{
    videoW = (int)width;
    videoH = (int)height;
    
    void *blackData = malloc(width * height * 1.5);
    if(blackData)
        //bzero(blackData, width * height * 1.5);
        memset(blackData, 0x0, width * height * 1.5);
    
    [EAGLContext setCurrentContext:glContext];
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXY]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, (int)width, (int)height, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData);
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXU]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, (int)width/2, (int)height/2, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + width * height);
    
    glBindTexture(GL_TEXTURE_2D, textureYUV[TEXV]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, (int)width/2, (int)height/2, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + width * height * 5 / 4);
    free(blackData);
}


- (void)clearFrame
{
    if ([self window])
    {
        [EAGLContext setCurrentContext:glContext];
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
        [glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
}


@end
