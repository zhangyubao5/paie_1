//
//  GetMuseumViewController.m
//  renwoxing
//
//  Created by YangBing on 16/3/29.
//  Copyright © 2016年 paixiao. All rights reserved.
//

#import "GetMuseumViewController.h"
#define  k_width [UIScreen mainScreen].bounds.size.width
#define  k_height [UIScreen mainScreen].bounds.size.height
@interface GetMuseumViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation GetMuseumViewController
-(NSMutableArray *)data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc]init];
    }
    return _data;
}
-(UITableView * )mytableView
{
    if (_mytableView == nil) {
        _mytableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, k_width, k_height-64) style:0];
        _mytableView.dataSource = self;
        _mytableView.delegate = self;
        [_mytableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:_mytableView];

        [self.view addSubview:_mytableView];
    }
    return _mytableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createNavBar];
    [self getOffesetUTCTimeSOAP];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.data.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    MuseumModel * model = self.data[indexPath.row];
    
    cell.textLabel.text = model.title;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetaileViewController * detVC = [[DetaileViewController alloc]init];
    
    MuseumModel * model = self.data[indexPath.row];
    detVC.HID = model._id;
    [self presentViewController:detVC animated:YES completion:^{
        
    }];
    //DetailsViewController * detai = [[DetailsViewController alloc]init];
   
    //[self.navigationController pushViewController:detai animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createNavBar
{
    UIImageView * navImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,k_width , 64)];
    
    navImgView.backgroundColor = [UIColor whiteColor];
    navImgView.userInteractionEnabled = YES;
    [self.view addSubview:navImgView];
    UILabel* titlebel = [[UILabel alloc]initWithFrame:CGRectMake(100, 20, k_width-200, 44)];
    
    titlebel.text = @"博物馆列表";
    
    titlebel.textColor = [UIColor blackColor];
    titlebel.textAlignment = NSTextAlignmentCenter;
    [navImgView addSubview:titlebel];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 27, 80, 40);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_btn_back_pressed@2x"] forState:0];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navImgView addSubview:backBtn];
}
-(void)backBtnClick
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)getOffesetUTCTimeSOAP{
    NSArray *languages = [NSLocale preferredLanguages];
  NSString * currentLanguage = [languages objectAtIndex:0];
    NSLog( @"%@" , currentLanguage);
    NSArray * arr1 = [currentLanguage componentsSeparatedByString:@"-"];
    currentLanguage = arr1[0];

    recordResults = NO;
    //封装soap请求消息
    NSLog(@"\n");
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<findConditionViews xmlns=\"http://impl.webservice.paile.com\">\n"
                             
                             
                             "<title>%@</title>\n"
                             "<limit>%d</limit>\n"
                             "<page>%d</page>\n"
                             "<language>%@</language>\n"
                             
                             "</findConditionViews>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",@"",50,1,@"zh"
                             ];
    NSLog(@"%@",soapMessage);
    //请求发送到的路径
    NSURL *url = [NSURL URLWithString:@"http://www.imapedia.com/services/EntryService?wsdl"];
    
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
///---------

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
    NSLog(@"connection: didReceiveResponse:1");
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    NSLog(@"connection: didReceiveData:2");
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
    NSLog(@"3 DONE. Received Bytes: %lu", (unsigned long)[webData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
   // NSLog(@"The:%@",theXML);
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
    
    NSData * data = [JsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * alldic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
   
    for (id obj in alldic[@"content"]) {
         MuseumModel * model = [[MuseumModel alloc]init];
        model.title = obj[@"title"];
        model._id = obj[@"_id"];
        [self.data addObject:model];
    }
    
    [self.mytableView reloadData];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    NSLog(@"4 parser didStarElemen: namespaceURI: attributes:");
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
