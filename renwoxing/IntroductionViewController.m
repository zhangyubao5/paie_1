

#import "IntroductionViewController.h"
#define K_width [UIScreen mainScreen].bounds.size.width
#define K_height [UIScreen mainScreen].bounds.size.height
@interface IntroductionViewController ()<UIScrollViewDelegate>

@end

@implementation IntroductionViewController
{
    UIPageControl *pageControl;
    NSInteger currentPage;
}
-(NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc]init];
    }
    return _data;
 

}
-(NSMutableData *)webData
{
    if (_webData == nil) {
        _webData = [[NSMutableData alloc]init];
    }
    return _webData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadAnimation];

    [self.activityIndicatorView startAnimating];
    [self getData:self.sid];
}
-(void)loadAnimation
{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityIndicatorView.center=self.view.center;
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    
    UIButton * button = [UIButton buttonWithType:0];
    button.frame = CGRectMake(10, 20, 80, 40);
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"取消" forState:0];
    [button addTarget:self action:@selector(cancelcompare) forControlEvents:UIControlEventTouchUpInside];
    [self.activityIndicatorView addSubview:button];

    UILabel * bel = [[UILabel alloc]initWithFrame:CGRectMake(K_width/2-30, K_width/2+50, 60, 30)];
    bel.text = @"比对中";
    bel.textAlignment = 1;
    [self.activityIndicatorView addSubview:bel];
    [self.activityIndicatorView setBackgroundColor:[UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:0.6]];
    [self.view addSubview:self.activityIndicatorView];
    
}
-(void)cancelcompare
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];

}
-(void)creatUI
{
    ResultModel * model = [[ResultModel alloc]init];
    model = self.data[0];
    self.titleLabel.text = model.title;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.autherLabel.text = model.author;
    self.autherLabel.adjustsFontSizeToFitWidth = YES;

    _detail = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, K_width, [model.descriptioheight integerValue])];
    _detail.font = [UIFont systemFontOfSize:15];
    _detail.numberOfLines = 0;
    [_detail setContentMode:UIViewContentModeTop];

    
    _detail.text = model.descriptio;
    self.currentdetail = model.descriptio;

    [self.connextScroller addSubview:_detail];
    self.connextScroller.bounces = NO;
    self.connextScroller.contentSize = CGSizeMake(K_width, _detail.frame.size.height);
    self.connextScroller.pagingEnabled = NO;
    
    for (NSInteger i = 0;i<self.data.count;i++) {
        model= self.data[i];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*K_width, 0, K_width, 150)];
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.img_src]]];
        
        [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
        
        imageView.contentMode =  UIViewContentModeCenter;
        
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        imageView.clipsToBounds  = NO;
        self.imgScroller.bounces = NO;
        [self.imgScroller addSubview:imageView];
    }
    self.imgScroller.contentSize = CGSizeMake(self.data.count*K_width, 150);
    self.imgScroller.showsHorizontalScrollIndicator= NO;
    
    self.imgScroller.pagingEnabled = YES;
    self.imgScroller.delegate = self;
    [self addpagecControl];
    [self.activityIndicatorView stopAnimating];
}

-(void)addpagecControl
{
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,self.imgScroller.frame.size.height+64-37, K_width, 37)];
    pageControl.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.01];
    //设置页数
    pageControl.numberOfPages = self.data.count;
    //当前选中的点
    pageControl.currentPage = 0;
    //设置点的颜色
    pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    //设置当前只有一个点的时候隐藏
    //pageControl.hidesForSinglePage = YES;
    //事件
    [pageControl addTarget:self action:@selector(pageValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];


}
-(void)pageValueChange:(UIPageControl *)page
{
    //NSLog(@"%ld",page.currentPage);
    [self.imgScroller setContentOffset:CGPointMake(page.currentPage * K_width, 0) animated:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"%lf",scrollView.contentOffset.x);
    int index = scrollView.contentOffset.x / 320;
    pageControl.currentPage = index;
    [self.av stopSpeakingAtBoundary:AVSpeechBoundaryWord];
    ResultModel * model = self.data[index];
    self.titleLabel.text = model.title;
    self.autherLabel.text = model.author;
    self.detail.text = model.descriptio;
    self.detail.frame =CGRectMake(0, 0, K_width, [model.descriptioheight integerValue]);
    self.connextScroller.contentSize = CGSizeMake(K_width, [model.descriptioheight integerValue]);
    self.readButton.selected = NO;
    [self.readButton setTitle:@"朗读" forState:0];
    self.currentdetail = model.descriptio;
}
-(void)getData:(NSString *)sid
{
    
    recordResults = NO;
    //封装soap请求消息
    NSLog(@"\n");
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             //在此改方法名及参数
                             "<findResultAndDetail xmlns=\"http://impl.webservice.paile.com\">\n"
                             
                             "<sid>%@</sid>\n"
                             
                             "</findResultAndDetail>\n"
                             //
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",
                            sid
                             ];
    //NSLog(@"%@",soapMessage);
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
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    //如果连接已经建好，则初始化data
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.webData setLength: 0];
    // NSLog(@"connection: didReceiveResponse:1");
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
    //NSLog(@"connection: didReceiveData:2");
}
//如果电脑没有连接网络，则出现此信息（不是网络服务器不通）
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误，请检查你的网络！ " preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定 " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    }]];
    [self presentViewController:alert animated:true completion: nil];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];

    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"3 DONE. Received Bytes: %lu", (unsigned long)[webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [self.webData mutableBytes] length:[self.webData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",theXML);
    
    if (theXML == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误，请检查你的网络！ " preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定 " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:true completion: nil];
        
        
    }
    
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    //得到json数据
     NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
    //进行解析
    [self AnalysisJson:JsonData];
}

//解析json
-(void)AnalysisJson:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * alldic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
    if (error) {
        NSLog(@"解析失败！===%@",error);
    }
     [self.data removeAllObjects];
    
    if ([alldic[@"code"] isEqualToString:@"000" ]) {
       
    for (id obj in alldic[@"content"]) {
        ResultModel * model = [[ResultModel alloc]init];
        model.total = alldic[@"total"];
        model.img_src = obj[@"img_src"];
        model.author = obj[@"author"];
        model.title = obj[@"title"];
        model.descriptio = obj[@"description"];
        model.voice_url = obj[@"voice_url"];
        [self.data addObject:model];
        
    }
        [self creatUI];
        
        }else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络错误，请检查你的网络！ " preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定 " style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:true completion: nil];
        

    }
    
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonClick:(UIButton *)sender {
   [ self.av stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (IBAction)ReadingButton:(UIButton *)sender {
    
    if (sender.selected == NO) {
        
        _av = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.currentdetail];  //需要转换的文本
        
        [_av speakUtterance:utterance];
        [sender setTitle:@"停止" forState:0];
        sender.selected = YES;
    }else
    {
        [_av stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
        [sender setTitle:@"朗读" forState:0];
        sender.selected = NO;
    }
    
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
