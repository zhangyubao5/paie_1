

#import "RootViewController.h"
#import "LeftTableViewController.h"
#import "CLLocation+YCLocation.h"
#import "CMuneBar.h"
#import <CommonCrypto/CommonDigest.h>

#define K_with [UIScreen mainScreen].bounds.size.width
#define K_height [UIScreen mainScreen].bounds.size.height
#define K_mapwidth [UIScreen mainScreen].bounds.size.width/6

@interface RootViewController ()<CMuneBarDelegate>
{
    BOOL _isChange;
    int theType;
    CGFloat lat;
    CGFloat lon;
    AMapSearchAPI *_search;
}
@property(nonatomic,strong)CMuneBar *muneBar;
//@property (nonatomic, strong) UIView *playView;
@end

@implementation RootViewController
@synthesize locManager;


- (id)initWithCenterVC:(RootViewController *)centerVC leftVC:(LeftTableViewController *)leftVC {
    if (self = [super init]) {
        [self addChildViewController:leftVC];
        UINavigationController *centerNC = [[UINavigationController alloc] initWithRootViewController:centerVC];
        [self addChildViewController:centerNC];
        [centerNC setNavigationBarHidden:YES];
        
        leftVC.view.frame = CGRectMake(0, 20, 250, [UIScreen mainScreen].bounds.size.height-20);
        
        
        centerNC.view.frame = [UIScreen mainScreen].bounds;
        [self.view addSubview:leftVC.view];
        [self.view addSubview:centerNC.view];
        
    }
    return self;
}

/**********************懒加载**************************************/
-(NSMutableArray * )data
{
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}
-(NSMutableArray *)pointData
{
    
    if (_pointData == nil) {
        _pointData = [NSMutableArray array];
    }
    return _pointData;
}
/************************************************************/
-(void)initgaodedata
{
    
    [AMapSearchServices sharedServices].apiKey = @"0d3b107540592033d1e5f8a9bf96cd13";
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    _request = [[AMapPOIAroundSearchRequest alloc] init];
    _request.location = [AMapGeoPoint locationWithLatitude:lat longitude:lon];
    // request.keywords = @"方恒";
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    //_request.types = @"餐饮服务";
    _request.sortrule = 0;
    _request.requireExtension = YES;
    _request.offset = 20;
    
    //发起周边搜索
    
    
}
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        NSLog(@"未返回数据！");
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    [self.data removeAllObjects];
    [self.pointData removeAllObjects];
    for (AMapPOI *p in response.pois) {
        SearchModel * model = [[SearchModel alloc]init];
        model.name = p.name;
        model.lon = p.location.longitude;
        model.lat = p.location.latitude;
        model.Content = p.address;
        model.tel = p.tel;
        model.distance = p.distance;
        
        if (p.distance <= 3000) {
            [self.data addObject:model];
            CGPoint point = [self takePointXYWithLat:model.lat AndLon:model.lon];
            [self.pointData addObject:NSStringFromCGPoint(point)];
            //  NSLog(@"%d",p.distance);
        }
    }
    
    
    [self reDrawUI];
    [self addButton];
}
/************************资源初始化************************************/
-(void)useGet
{
    //1,url
    NSString * city = @"长沙";
    NSString * subcity = @"开福区";
    NSString * version=@"0";
    
    NSString * url = [NSString stringWithFormat:@"http://www.imapedia.com:8088/PaileVR/scene/findscenepkg"];
    NSLog(@"%@",url);
    
    NSDictionary *parameter=@{@"city": city,@"district": subcity,@"version": version};
    //2, 创建HTTP请求管理器对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //报错:Request failed: unacceptable content-type: text/html"
    //解决方法一: 设置接收的内容类型为"text/html"
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //解决方法二: 设置返回的数据类型为二进制NSData
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //3, 发送GET请求
    [manager GET:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"success");
        
        //JSON解析:将二进制转换成JSON对象(字典or数组)
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",responseDict);
        self.zipURl = responseDict[@"content"][@"path"];
        
        [self loadZip];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", error);
    }];
    
}

-(NSString*)DownloadTextFile:(NSString*)fileUrl   fileName:(NSString*)_fileName
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
    NSLog(@"%@",documentPaths);
    
    //NSString *sandboxPath = NSHomeDirectory();
    // NSLog(@"%@",sandboxPath);
    //    NSString *documentPath = [sandboxPath  stringByAppendingPathComponent:@"kaifuqu.app"];//将Documents添加到sandbox路径上//TestDownImgZip.app
    //    NSLog(@"%@",documentPath);
    NSString *FileName=[documentPaths[0] stringByAppendingPathComponent:_fileName];//fileName就是保存文件的文件名
    NSLog(@"%@",FileName);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Copy the database sql file from the resourcepath to the documentpath
    if ([fileManager fileExistsAtPath:FileName])
    {
        NSLog(@"文件已存在!");
        return FileName;
    }else
    {
        NSURL *url = [NSURL URLWithString:fileUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:FileName atomically:YES];//将NSData类型对象data写入文件，文件名为FileName
        NSLog(@"下载成功!");
    }
    return FileName;
}
-(void)loadZip{
    NSLog(@"下载中！");
    NSString *filePath = [self DownloadTextFile:self.zipURl fileName:@"img.zip"];
    
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
    // NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
    //NSString *sandboxPath = NSHomeDirectory();
    NSString *documentPath = [documentPaths[0]  stringByAppendingPathComponent:@"assets"];//将Documents添加到sandbox路径上//TestDownImgZip.app
    NSLog(@"%@",documentPath);
    NSLog(@"解压中！");
    [self OpenZip:filePath unzipto:documentPath];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    dispatch_async(queue, ^{    //开启一异步线程将数据写入数据库
        [self readFile];
    });
    
}

- (void)OpenZip:(NSString*)zipPath  unzipto:(NSString*)_unzipto
{
    ZipArchive * zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:zipPath] )
    {
        BOOL ret = [zip UnzipFileTo:_unzipto overWrite:YES];
        if( NO==ret )
        {
            NSLog(@"error");
        }else
        {
            NSLog(@"解压成功！");
        }
        [zip UnzipCloseFile];
    }
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    //
    //    dispatch_async(queue, ^{
    //
    //[self.glView start];
    //
    //    });
    [self.glView start];
}


-(void)readFile
{
    NSLog(@"开始写入数据库！");
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *documentPath = [documentPaths[0]  stringByAppendingPathComponent:@"assets"];
    NSString * paths = [documentPath stringByAppendingString:@"/datas.json"];
    NSLog(@"%@",paths);
    
    NSString * Contents = [[NSString alloc]initWithContentsOfFile:paths encoding:NSUTF8StringEncoding error:nil];
    NSData * jsondata = [Contents dataUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"%@",Contents);
    NSArray * arr =  [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingAllowFragments error:nil];
    //NSLog(@"%@",arr);
    for (NSDictionary * modelDic in arr) {
        HQModel * model = [[HQModel alloc]init];
        model.scene_id = modelDic[@"scene_id"];
        model.name = modelDic[@"name"];
        model.image1 = modelDic[@"image1"];
        model.image2 = modelDic[@"image2"];
        model.descript = modelDic[@"description"];
        model.lng = modelDic[@"lng"];
        model.lat = modelDic[@"lat"];
        model.optype = modelDic[@"optype"];
        //NSLog(@"%@",model);
        CYDataBase * Database = [CYDataBase sharedDataBase];
        [Database insertData:model];
    }
    
    NSLog(@"写入完成！");
}

/************************************************************/

/**********************控制器加载完成********************************/

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.session startRunning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    theType = 3;
    self.From = 1;
    self.curentRadius = 3000;
    
    [self useGet];
    self.glView = [OpenGLView share];
    [self.view addSubview:self.glView];
    [self.glView setOrientation:self.interfaceOrientation];
    
    [self loadlocationAndDirection];
    
    [self addsplitPaging];
    [self drawCircle];
    [self Category];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.glView setOrientation:toInterfaceOrientation];
    
}

/**********************开启分页********************************/
- (void)addsplitPaging {
    
    //self.liveView.backgroundColor = [UIColor brownColor];
    
    // 轻扫手势
    UISwipeGestureRecognizer *leftswipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftswipeGestureAction:)];
    
    // 设置清扫手势支持的方向
    leftswipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    // 添加手势
    [self.view addGestureRecognizer:leftswipeGesture];
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightswipeGestureAction:)];
    
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:rightSwipeGesture];
    
    // Do any additional setup after loading the view.
}
/**
 *  左轻扫
 */
- (void)leftswipeGestureAction:(UISwipeGestureRecognizer *)sender {
    
    UINavigationController *centerNC = self.navigationController;
    
    LeftTableViewController *leftVC  = self.navigationController.parentViewController.childViewControllers[0];
    [UIView animateWithDuration:0.5 animations:^{
        
        
        if ( centerNC.view.center.x != self.view.center.x ) {
            
           
            
            
            NSLog(@"1回来");
            leftVC.view.frame = CGRectMake(0, 0, 250, [UIScreen mainScreen].bounds.size.height);
            centerNC.view.frame = [UIScreen mainScreen].bounds;
            _isChange = !_isChange;
            return;
        }}];
}

/**
 *  右轻扫
 */
- (void)rightswipeGestureAction:(UISwipeGestureRecognizer *)sender {
    UINavigationController *centerNC = self.navigationController;
    [UIView animateWithDuration:0.5 animations:^{
        if ( centerNC.view.center.x == self.view.center.x ) {
            
             [self reDrawUI];
            centerNC.view.frame = CGRectMake(250, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }
    }];
}
/***************************************************************/

/****************************获取方向***********************************/

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", [error description]);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    arrow.transform = CGAffineTransformIdentity;
    CGFloat heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * M_PI*newHeading.magneticHeading/180.0);
    arrow.transform = transform;
    _azimuth_angle =newHeading.magneticHeading;
    // _angel.text=[[NSString alloc]initWithFormat:@"angle:%f",newHeading.magneticHeading];
    self.transform = CGAffineTransformMakeRotation(-heading);
    [arrow removeFromSuperview];
    
    [self drawCircle];

    
    [self changeButton];
    
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

/************************************************************/
#pragma mark CLLocationManagerDelegate
//获取经纬度的代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    CLLocation * marsLoction =   [location locationMarsFromEarth];
   // NSLog(@"%f--%f",marsLoction.coordinate.latitude,marsLoction.coordinate.longitude);
    
    lat = marsLoction.coordinate.latitude;
    lon = marsLoction.coordinate.longitude;
    NSLog(@"%f,%f",lat,lon);
    //刷新数据
    
    if (_search == nil) {
        [self initgaodedata];
    }
    
    if (theType == 0) {
        
        [self loadData:@"景点"];
    }if (theType == 1) {//美食
        
        _request.types = @"餐饮服务";
        [_search AMapPOIAroundSearch: _request];
        
    }if (theType == 2) {//购物
        
        _request.types = @"购物服务";
        [_search AMapPOIAroundSearch: _request];
    }
    if (theType == 3) {
        
        [self loadData:@"博物馆"];
    }
}
/************************************************************/

/**********************定位及传感器****************************/
-(void)loadlocationAndDirection//创建定位及方向
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        self.locManager = [[CLLocationManager alloc] init];
        //设置定位精度（可优化）
        self.locManager.delegate = self;
        [self.locManager setDesiredAccuracy:kCLLocationAccuracyBest];
        self.locManager.distanceFilter =100;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f)
        {
            [self.locManager requestAlwaysAuthorization];
        }
        [locManager startUpdatingLocation];
    }
    if ([CLLocationManager headingAvailable]){
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        //self.locManager.headingFilter = kCLHeadingFilterNone;
        [self.locManager startUpdatingHeading];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"atention" message:@"compass not Available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        arrow.alpha = 0.0f;
    }
}
/************************************************************/


/****************************卫星按钮***********************************/
-(void)Category
{
    CMuneBar *muneBar = [[CMuneBar alloc] initWithItems:@[@"jingdian",@"food",@"gouwu",@"house"] size:CGSizeMake(40, 40) type:kMuneBarTypeRadLeft];
    muneBar.delegate = self;
    muneBar.center = CGPointMake(30, 100);
    [self.view addSubview:muneBar];
    self.muneBar = muneBar;
}
//卫星按钮触发事件
-(void)muneBarselected:(NSInteger)index{
    NSLog(@"%d",index);
    [self.muneBar hideItems];
    if (_search == nil) {
        [self initgaodedata];
    }
    theType = index;
    if (index == 0) {
        
        [self loadData:@"景点"];
    }if (index == 1) {//美食
        
        _request.types = @"餐饮服务";
        [_search AMapPOIAroundSearch: _request];
        
    }if (index == 2) {//购物
        
        _request.types = @"购物服务";
        [_search AMapPOIAroundSearch: _request];
    }
    if (index == 3) {
        
        [self loadData:@"博物馆"];
    }
}

/**********************************************************************/
/**********************画小地图******************************/

-(void)drawCircle
{
    [arrow removeFromSuperview];
    arrow = [[Drawview alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-K_mapwidth*2-20, 20, K_mapwidth*2+20, K_mapwidth*2+20)];
    
    
    arrow.Proportion = self.curentRadius/3000*(K_mapwidth+20) ;
    
    arrow.transform = self.transform;
    arrow.layer.masksToBounds = YES;
    arrow.layer.cornerRadius = K_mapwidth+10;
    arrow.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    [self.glView addSubview:arrow];
    
}
/************************************************************/

/*******************获取数据*********************************/
-(void)loadData:(NSString *)cname
{
    
    recordResults = NO;
    //封装soap请求消息
    NSLog(@"\n");
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             //在此改方法名及参数
                             "<findAroundDatas xmlns=\"http://impl.webservice.paile.com\">\n"
                             "<cname>%@</cname>\n"
                             "<language>%@</language>\n"
                             "<lat>%@</lat>\n"
                             "<lon>%@</lon>\n"
                             "</findAroundDatas>\n"
                             //
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",
                             cname,@"ch",[NSString stringWithFormat:@"%f",lat ],[NSString stringWithFormat:@"%f",lon]
                             ];
    //NSLog(@"%@",soapMessage);
    //请求发送到的路径
    NSURL *url = [NSURL URLWithString:@"http://www.imapedia.com/services/ViewAroundService?wsdl"];
    
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
    if( theConnection )
    {
        webData = [NSMutableData data];
        
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
    // NSLog(@"connection: didReceiveResponse:1");
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    //NSLog(@"connection: didReceiveData:2");
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
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    
    //得到json数据
    // NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
    //进行解析
    [self AnalysisJson:JsonData];
}

//解析json
-(void)AnalysisJson:(NSString *)string
{
    [self.data removeAllObjects];
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * alldic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
    if (error) {
        NSLog(@"解析失败！===%@",error);
    }
    
    [self.data removeAllObjects];
    [self.pointData removeAllObjects];
    for (id obj in alldic[@"content"]) {
        SearchModel * model = [[SearchModel alloc]init];
        model.name = obj[@"title"];
        model.lon = [obj[@"lon"] floatValue];
        model.lat = [obj[@"lat"] floatValue];
        model.Content = obj[@"content"];
        model.Hid =obj[@"_id"];
        
        CLLocation *orig=[[CLLocation alloc]initWithLatitude:lat longitude:lon];
        CLLocation* dist=[[CLLocation alloc] initWithLatitude:model.lat longitude:model.lon];
        
        CLLocationDistance kilometers=[orig distanceFromLocation:dist];
        
        model.distance = kilometers;
        //NSLog(@"%@经纬度为%f %f",model.name,model.lat,model.lon);
        NSLog(@"%@距离:%f",model.name,kilometers);
        
        if (kilometers <= 3000) {
            [self.data addObject:model];
            
            
            CGPoint point = [self takePointXYWithLat:model.lat AndLon:model.lon];
          //  NSLog(@"%f,%f",model.lat,model.lon);
            
            [self.pointData addObject:NSStringFromCGPoint(point)];
            
        }
        
    }
   
    
    [self addButton];
    [self reDrawUI];
    // NSLog(@"-------------------------%d",self.data.count);
    
    // [self creatArray];
    
}
-(void)reDrawUI
{
    //if(_drawpoint != nil){
        [_drawpoint removeFromSuperview];
    //}
    _drawpoint = [[DrawPoint alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-K_mapwidth*2-20, 20, K_mapwidth*2+20, K_mapwidth*2+20)];
    //_drawpoint = [[DrawPoint alloc]initWithFrame:arrow.frame];
    _drawpoint.backgroundColor = [UIColor purpleColor];
    
    _drawpoint.layer.masksToBounds = YES;
    _drawpoint.layer.cornerRadius = K_mapwidth+10;
    _drawpoint.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [_drawpoint.datapoint removeAllObjects];
    _drawpoint.datapoint = self.pointData;
    [self.glView addSubview:_drawpoint];
    
}
-(CGPoint)takePointXYWithLat:(float)goalLat AndLon:(float)goalLon
{
    CGPoint  point ;
    //(100+(Double.parseDouble(poi.getLon())-Trail.localLon)*45*canshu)
    point.x =(K_mapwidth+10 + ((goalLon-lon)*K_mapwidth*100000/3000));
    //,(float)(100+(Trail.localLat-Double.parseDouble(poi.getLat()))*45*canshu),
    point.y =(K_mapwidth+10+((lat-goalLat)*K_mapwidth*100000/3000));
    
    return point;
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
/************************************************************/

/***********************添加touch方法*****************************/
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    self.beganPoint = [touches.anyObject locationInView:self.liveView ];
//
//
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
//{
//    self.endPoint =  [touches.anyObject locationInView:self.view ];
//    float y = self.endPoint.y - self.beganPoint.y;
//    //float x = self.endPoint.y - self.beganPoint.x;
//    //x = fabsf(x);
//    //if (x > fabsf(y)) {
//
//    //}else{
//        [self chageframe:y];
//    //}
//
//
//}
//-(void)chageframe:(float)y
//{
//    self.From = y / K_height*self.curentRadius;
//    self.curentRadius = self.curentRadius + self.From;
//    if (self.curentRadius > 3000) {
//        self.curentRadius = 3000;
//    }if (self.curentRadius< 1000) {
//        self.curentRadius = 1000;
//    }
//    //[self drawCircle];
//    //[self changeButton];
//
//}


/************************************************************/

/**********************画标签按钮*****************************/
-(void)addButton
{
    
    NSArray *subViews = [_glView subviews];
    if([subViews count] != 0) {
        
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self reDrawUI];
    
    SearchModel * model = [[SearchModel alloc]init];
    for (NSInteger i=0; i < self.data.count; i++) {
        model = self.data[i];
        //创建button
        DefinitionButton * but = [DefinitionButton buttonWithType:0];
        [but setTag:110+i];
        but.Hmodel = model;
        [but setTitleColor:[UIColor blackColor] forState:0];
        but.backgroundColor = [UIColor whiteColor];
        //but.frame = CGRectMake(0, 0, 50, 20) ;
        but.hidden = YES;
        but.layer.masksToBounds = YES;
        but.layer.cornerRadius = 5;
        [but setTitle:model.name forState:0];
        if (theType == 0|| theType == 3) {
            [but addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
        }if (theType ==1 ||theType ==2 ) {
            [but addTarget:self action:@selector(ShopShowView:) forControlEvents:UIControlEventTouchUpInside];
        }
        [_glView addSubview:but];
    }
}




-(void)changeButton
{
    
    SearchModel * model = [[SearchModel alloc]init];
    for (NSInteger i=0; i < self.data.count; i++) {
        model = self.data[i];
        
        
        double subLng = model.lon-lon;
        double subLat  = lat - model.lat;
        double  juli = sqrt(subLat*subLat + subLng * subLng);
        
        double fAngCos = (cos((_azimuth_angle-90)*M_PI/180)
                          *subLng+sin((_azimuth_angle-90)*M_PI/180)
                          *subLat)/juli;
        double fAngle = acos(fAngCos)*180/M_PI;
        // NSLog(@"fAngle:%f",fAngle);
        if (fAngle>-30&&fAngle<30) {
            double fSign = subLng*sin((_azimuth_angle -90)*M_PI/180)
            -(subLat)
            *cos((_azimuth_angle-90)*M_PI/180);
            if (fSign>0) {
                fAngle*=-1;
            }
           // float xx = (float)juli * (K_height-20-150)/(self.curentRadius)*100000;
            //NSLog(@"%f",xx);
            //int moveX = K_with/2+sin(fAngle)*xx;
            //int moveY = (K_height -20 - 150-cos(fAngle)*xx  );
            
            int moveX = K_with/2+K_with*fAngle/60-60;
            
            int moveY = (K_height - 40-10)/(self.data.count-1)*(i);
            
            UIFont *font = [UIFont fontWithName:@"Arial" size:10];
            CGSize size = [model.name sizeWithAttributes:@{NSFontAttributeName : font}];
            UIButton *find_button = (UIButton *)[self.view viewWithTag:110+i];
            find_button.hidden = NO;
            find_button.frame =CGRectMake(moveX, moveY, size.width*2, 20) ;
            
        }else{
            UIButton *find_button = (UIButton *)[self.view viewWithTag:110+i];
            find_button.hidden = YES;
            
            
        }
    }
}
//-(void)changeButton
//{
//
//    SearchModel * model = [[SearchModel alloc]init];
//    for (NSInteger i=0; i < self.data.count; i++) {
//        model = self.data[i];
//
//        double subLng = model.lon-lon;
//        double subLat  = lat - model.lat;
//        double  juli = sqrt(subLat*subLat + subLng * subLng);
//
//        double fAngCos = (cos((_azimuth_angle-90)*M_PI/180)
//                          *subLng+sin((_azimuth_angle-90)*M_PI/180)
//                          *subLat)/juli;
//        double fAngle = acos(fAngCos);
//        double fSign = subLng
//        *sin((_azimuth_angle-90)*M_PI/180)-subLat
//        *cos((_azimuth_angle-90)*M_PI/180);
//        if ((fAngle > 0)&&(fAngle < M_PI/2)) {
//            if (fSign > 0) {
//                fAngle *= -1;
//            }
//            int xx = 400 * juli;
//            int moveX = K_with/2+sin(fAngle)*xx;
//            int moveY = K_height - cos(fAngle)*xx;
//
//            UIFont *font = [UIFont fontWithName:@"Arial" size:10];
//            CGSize size = [model.name sizeWithAttributes:@{NSFontAttributeName : font}];
//            UIButton *find_button = (UIButton *)[self.view viewWithTag:110+i];
//            find_button.hidden = NO;
//            find_button.frame =CGRectMake(moveX, moveY, size.width*2, 20) ;
//
//
//
//
//        }
//
//    }
//}




-(void)showView:(DefinitionButton *)sender//
{
    
    _showview = [ShowView instanceTextView];
    [_showview.titleButton setTitle:sender.Hmodel.name forState:0];
    _showview.From.text =[NSString stringWithFormat:@"%dm",sender.Hmodel.distance] ;
    _showview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _showview.scrollVi.bounces = NO;
    _showview.scrollVi.alwaysBounceVertical = YES;
    float  height =[sender.Hmodel.contentHeight floatValue];
    CGSize size = {_showview.showMainview.frame.size.width,height};
    _showview.scrollVi.contentSize =size ;
    self.connextLabel =[[UILabel alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    self.connextLabel.numberOfLines = 0;
    self.connextLabel.font = [UIFont systemFontOfSize:15];
    self.connextLabel.text = sender.Hmodel.Content;
    [_showview.scrollVi addSubview:self.connextLabel];
    
    
    self.Hid = sender.Hmodel.Hid;
    [self.view addSubview:_showview];
    if (theType == 0|| theType == 3) {
        [_showview.titleButton addTarget:self action:@selector(PushNextcontroller) forControlEvents:UIControlEventTouchUpInside];
    }
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteView)];
    
    [_showview addGestureRecognizer:tap];
    
    
}
-(void)ShopShowView:(DefinitionButton *)sender
{
    _shopShowView = [ShopShowView instanceTextView];
    _shopShowView.titltLabel.text =  sender.Hmodel.name ;
    _shopShowView.distanceLabel.text =[NSString stringWithFormat:@"距离：%dm",sender.Hmodel.distance] ;
    self.Hid = sender.Hmodel.Hid;
    _shopShowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _shopShowView.telLabel.text = [NSString stringWithFormat:@"电话：%@",sender.Hmodel.tel];
    _shopShowView.telLabel.adjustsFontSizeToFitWidth = YES;
    _shopShowView.addressLabel.text = sender.Hmodel.Content;
    _shopShowView.addressLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_shopShowView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteShopView)];
    
    [_shopShowView addGestureRecognizer:tap];
    
    
    
    
}
//跳转
-(void)PushNextcontroller
{
    [self.session stopRunning];
    DetaileViewController * detailVC = [[DetaileViewController alloc]init];
    detailVC.lat = [NSString stringWithFormat:@"%f",lat];
    detailVC.lon = [NSString stringWithFormat:@"%f",lon];
    detailVC.HID = self.Hid;
    [self presentViewController:detailVC animated:NO completion:^{
        
    }];
    
    
    
}


-(void)deleteShopView
{
    [_shopShowView removeFromSuperview];
    
}
-(void)deleteView
{
    [_showview removeFromSuperview];
    
    
}
/************************************************************/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end













