//





#import "DetaileViewController.h"
#define k_height [UIScreen mainScreen].bounds.size.height
#define k_width [UIScreen mainScreen].bounds.size.width
@interface DetaileViewController ()<NSURLConnectionDataDelegate>

@end
@implementation DetaileViewController

-(NSMutableData *)webData
{
    if (_webData == nil) {
        _webData = [[NSMutableData alloc]init];
        
    }
    return _webData;
}
-(UIImageView *)preView
{
    if (_preView == nil) {
        _preView = [[UIImageView alloc]initWithFrame:CGRectMake(-10, 0, self.liveView.frame.size.width+20, self.liveView.frame.size.height)];
        [_preView addSubview:self.rectanglView];
        _preView.userInteractionEnabled = YES;
        _preView.hidden = YES;
        
        [self.liveView addSubview:_preView];
    }
    
    return _preView;
}
-(RectangleRectanglView *)rectanglView
{
    if (_rectanglView == nil) {
        _rectanglView = [[RectangleRectanglView alloc]initWithFrame:CGRectMake(10, 0, self.preView.frame.size.width-20, self.preView.frame.size.height)];
        //CGRectMake(0, 64, self.view.frame.size.width, (self.view.frame.size.height-64)/2
        _rectanglView.backgroundColor = [UIColor clearColor];
    
    }
    return _rectanglView;
}
-(UIView *)butView
{
    if (_butView == nil) {
        _butView = [[UIView alloc]initWithFrame:CGRectMake(0,(k_height -64)/2+64,k_width, (k_height -64)/2)];
    }
    
    return _butView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    [self.butView setBackgroundColor:[UIColor whiteColor]];
    self.CompareButton.hidden = YES;
    [self openCamera];
    [self setUpGesture];
    [self loadAnimation];
    self.effectiveScale = self.beginGestureScale = 1.0f;
}
-(void)openCamera
{
    _session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetMedium];
    NSError * error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.liveView.layer.masksToBounds = YES;
    [self.liveView.layer addSublayer:self.previewLayer];
    [self.session startRunning];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setUpGesture{
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.liveView addGestureRecognizer:pinch];
}

//捏合手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.liveView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        //NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
       // NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClick:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

//拍照按钮
- (IBAction)snap:(UIButton *)sender {
    
    
    
    if (![sender isSelected]) {
        self.preView.image = nil;
        
//        NSString* date;
//        NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
//        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
//        date = [formatter stringFromDate:[NSDate date]];
       
        NSDate* tmpStartData = [NSDate date];
                                
        [self showcurnetImage];
        [sender setTitle:@"重拍" forState:0];
        sender.selected = YES;
        self.CompareButton.hidden= NO;
        double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
        NSLog(@">>>>>>>>>>拍照时间 time = %f ms", deltaTime*1000);
    }else
    {
        [self.preView setHidden:YES];
        [sender setTitle:@"拍照" forState:0];
        sender.selected = NO;
        self.CompareButton.hidden = YES;
    }
    
    
    
    
    }
//等待加载动画
-(void)loadAnimation
{
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityIndicatorView.center=self.view.center;
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicatorView setBackgroundColor:[UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:0.4]];
    
    UIButton * button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(10, 20, 80, 40);
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"取消" forState:0];
    [button addTarget:self action:@selector(cancelcompare) forControlEvents:UIControlEventTouchUpInside];
    [self.activityIndicatorView addSubview:button];
    
    [self.view addSubview:self.activityIndicatorView];
    
}
-(void)cancelcompare
{
    [self.activityIndicatorView stopAnimating];


}
//比对按钮
- (IBAction)Compared:(UIButton *)sender {
    
     NSDate* tmpStartData = [NSDate date];
    [self.activityIndicatorView startAnimating];

    NSLog(@"%f,%f",self.rectanglView.beganPoint.x,self.rectanglView.beganPoint.y);
     NSLog(@"%f,%f",self.rectanglView.endPoint.x,self.rectanglView.endPoint.y);
    CGRect rect = CGRectMake(self.rectanglView.beganPoint.x, self.rectanglView.beganPoint.y, self.rectanglView.endPoint.x-self.rectanglView.beganPoint.x, self.rectanglView.endPoint.y-self.rectanglView.beganPoint.y);
    NSLog(@"%@",NSStringFromCGRect(rect));
    if (rect.size.width == 0) {
        rect = self.rectanglView.frame;
    }
    CGRect retanglerect = CGRectStandardize(rect);
    _cutImage = [[UIImage alloc]init];
    _cutImage = [self crop:self.preView.image Andrect:retanglerect];
    
    UIImageWriteToSavedPhotosAlbum(_cutImage, self,  nil , nil ) ;
   // self.cutimageview.image = _cutImage;
    NSData * data = UIImageJPEGRepresentation(_cutImage, 1.0f);
    self.base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@">>>>>>>>>>截图时间 time = %f ms", deltaTime*1000);
    
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    
    _Upmsecond1 = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"_Upmsecond1:%llu",_Upmsecond1);
    
    
    [self getOffesetUTCTimeSOAP:self.base64];
}

//把图片抠下来
-(UIImage *)crop:(UIImage*)image Andrect:(CGRect)rect//传入需要截取的照片和大小
{
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [image scale]);
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage *retuimag = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retuimag;
}
//展示拍好的照片
-(void)showcurnetImage
{
    self.preView.hidden = NO;
    //self.preView.backgroundColor = [UIColor yellowColor];
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput        connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
     [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * imag = [UIImage imageWithData:jpegData];
        self.preView.image = imag;
        CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                    imageDataSampleBuffer,
                                    kCMAttachmentMode_ShouldPropagate);
     }];
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

- (void)getOffesetUTCTimeSOAP:(NSString *)data
{
    recordResults = NO;
    //封装soap请求消息
    NSLog(@"\n");
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<uploadJingDianPic xmlns=\"http://impl.webservice.paile.com\">\n"
                             
                             
                             "<b_files>%@</b_files>\n"
                             "<loc>{lat:\"%@\" , lon:\"%@\"}</loc>\n"
                             "<language>%@</language>\n"
                             "<view_id>%@</view_id>\n"
                             
                             "</uploadJingDianPic>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",data,@"1",@"1",@"ch",self.HID                            ];
   
    NSLog(@"%@",soapMessage);
    //请求发送到的路径
    NSURL *url = [NSURL URLWithString:@"http://www.imapedia.com/services/UploadPicService?wsdl"];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://www.imapedia.com/services/UploadPicService" forHTTPHeaderField:@"SOAPAction"];
    
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody : [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //请求
       NSURLConnection * xxs = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

    //如果连接已经建好，则初始化data
    //    if( theConnection )
    //    {
    //        self.webData = [NSMutableData data];
    //
    //    }
    //    else
    //    {
    //        NSLog(@"theConnection is NULL");
    //    }
}
///---------

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[webData setLength: 0];
    self.webData.length = 0;
    // NSLog(@"connection: didReceiveResponse:1");
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
    // NSLog(@"connection: didReceiveData:2");
}
//如果电脑没有连接网络，则出现此信息（不是网络服务器不通）
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction");
    // [connection release];
    //[webData release];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
    //NSLog(@"3 DONE. Received Bytes: %lu", (unsigned long)[self.webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [self.webData mutableBytes] length:[self.webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"The:%@",theXML);
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
   
    _Upmsecond2 = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"上传时间：%llu ms", _Upmsecond2 - _Upmsecond1);
   
    NSData * jsData = [JsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsData options:NSJSONReadingMutableContainers error:nil];
    self.SID =dic[@"content"];
    IntroductionViewController * intr = [[IntroductionViewController alloc]init];
    intr.sid = self.SID;
   [self.activityIndicatorView stopAnimating];
    [self presentViewController:intr animated:YES completion:^{
        
    }];
    
    }
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    
    if( [elementName isEqualToString:@"getOffesetUTCTimeResult"])
    {
        if(!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        recordResults = YES;
    }
    
}
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------start--------------");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------end--------------");
}




@end
