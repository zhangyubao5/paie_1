/**
 * Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
 * EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
 * and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
 */

#import "OpenGLView.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"
//#import "iToast.h"
/*
 * Steps to create the key for this sample:
 *  1. login www.easyar.com
 *  2. create app with
 *      Name: HelloAR
 *      Bundle ID: cn.easyar.samples.helloar
 *  3. find the created item in the list and show key
 *  4. set key string bellow
 */


@interface OpenGLView ()
{
}

@property(nonatomic, strong) CADisplayLink * displayLink;

- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView
NSString* key = @"ee82fccf4f0224418a48533234981f9fletr9wPzoGWaRAVQBHIiolDPUE6IEOIjaPwR9El442lPZUmsyg4s4DevMAwT8bCiinG2FkknAU7NAYJzAGVJ7CsjlhUriYWfLdDL0guPKF45ns5yiknOp21xvfOQlz3DCh0FEqrVmrDF3CK1UzOTnHMU8rEVe5C8agWJiccj";

namespace EasyAR{
    namespace samples{
        
        class HelloAR : public AR
        {
        public:
            HelloAR();
            virtual void initGL();
            virtual void resizeGL(int width, int height);
            virtual void render();
        private:
            Vec2I view_size;
            Renderer renderer;
        };
        
        HelloAR::HelloAR()
        {
            view_size[0] = -1;
            
        }
        
        void HelloAR::initGL()
        {
            renderer.init();
            augmenter_ = Augmenter();
        }
        
        void HelloAR::resizeGL(int width, int height)
        {
            view_size = Vec2I(width, height);
        }
        
        void HelloAR::render()
        {
            glClearColor(0.f, 0.f, 0.f, 1.f);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            Frame frame = augmenter_.newFrame(tracker_);
            if(view_size[0] > 0){
                int width = view_size[0];
                int height = view_size[1];
                Vec2I size = Vec2I(1, 1);
                if (camera_ && camera_.isOpened())
                    size = camera_.size();
                if(portrait_)
                    std::swap(size[0], size[1]);
                float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
                Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
                if(portrait_)
                    augmenter_.setViewPort(Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]));
                else
                    augmenter_.setViewPort(Vec4I(0, width - height, viewport_size[0], viewport_size[1]));
                if(camera_ && camera_.isOpened())
                    view_size[0] = -1;
            }
            augmenter_.drawVideoBackground();
            
            AugmentedTarget::Status status = frame.targets()[0].status();
            if(status == AugmentedTarget::kTargetStatusTracked){
                Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
                Matrix44F cameraview = getPoseGL(frame.targets()[0].pose());
                ImageTarget target = frame.targets()[0].target().cast_dynamic<ImageTarget>();
                NSLog(@"%s",target.name());
                renderer.render(projectionMatrix, cameraview, target.size());
                NSString * toastname = [NSString stringWithFormat:@"%s",target.name()];
                //[iToast showWithText:toastname bottomOffset:3 duration:5];
                
                //  NSString * webstring =[NSString stringWithFormat:@"http://www.imapedia.com:8088/PaileVR/admin/user/scenepage?image_id=%@",toastname];
                //webView = [UIWebView alloc]initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
                
                OpenGLView *open= [OpenGLView share];///////////////////////////////////////////////////////////
                
                [open edit:toastname];
                // UITapGestureRecognizer* singleRecognizer;
                // singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:bview action:@selector(SingleTap: )];
                //给self.view添加一个手势监测；
                // [bview addGestureRecognizer:singleRecognizer];
                
                //                [view makeToast:toastname
                //                       duration:2.0
                //                       position:CSToastPositionCenter
                //                          title:nil
                //                          image:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",toastname]]
                //                          style:nil
                //                     completion:nil];
            }
        }
        
    }
}
-(void)SingleTap
{
    
}
EasyAR::samples::HelloAR ar;
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setupGL];
        
        EasyAR::initialize([key UTF8String]);
        ar.initGL();
    }
    
    return self;
}

- (void)dealloc
{
    ar.clear();
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}

- (void)start{
    ar.initCamera();
    
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"targets2" ofType:@"json"];
//    
//    //根据文件路径读取数据
//    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
//    //格式化成json数据
//    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:nil];
//    
//    NSLog(@"%@",jsonObject);
    
    NSString * imname = @"test.jpg";
    std::string str = [imname UTF8String];
    ar.loadFromImage(str);
    
   // ar.loadFromJsonFile("targets.json", "argame");
    //ar.loadFromJsonFile("targets.json", "idback");
   // ar.loadAllFromJsonFile("targets2.json");
    ar.loadFromImage("namecard.jpg");
    // 1:下载
    //2 解压 /data/pics/....
    NSString * docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/assets/imgs"];
    NSLog(@"%@",docPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:docPath error:nil];
    
    for (NSString * imgName in array) {
        NSLog(@"%@",imgName);
        NSString * string = [NSString stringWithFormat:@"%@/%@",docPath,imgName];
        NSLog(@"%@",string);
        std::string str = [string UTF8String];
        ar.loadFromImage(str);

    }
//    for im : imgs{
//        NSString imname;
//        std::string str = convert(imname);
//        ar.loadFromImage(str);
//    }
    
    ar.start();
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop
{
    ar.clear();
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    ar.render();
    
    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}
+(OpenGLView *)share
{
    
    static  OpenGLView *open=nil;
    
    if (open==nil) {
        
        open=[[OpenGLView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return open;
}

-(void)edit:(NSString *)scene_id
{
    NSString  * str = [[scene_id componentsSeparatedByString:@"/"]lastObject];
    NSLog(@"%@",str);
    // UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView * view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, 320, 480);
    CYDataBase * database = [CYDataBase sharedDataBase];
   HQModel * mod = [database SearchModelFromName:str];
    NSLog(@"%@%@",mod.name,mod.descript);
    [view makeToast:mod.descript
           duration:2.0
           position:CSToastPositionCenter
              title:nil
              image:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",scene_id]]
              style:nil
         completion:nil];
    [self addSubview:view];
    //自行长处理
}

@end
