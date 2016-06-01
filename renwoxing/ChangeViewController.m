

#import "ChangeViewController.h"
#define k_width [UIScreen mainScreen].bounds.size.width
@interface ChangeViewController ()

@end

@implementation ChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createNavBar];
    [self creatTextFeild];
   }

-(void)creatTextFeild
{
    switch (self.index) {
        case 0:
            
            self.textField.text = self.User;
            self.textField.placeholder = @"请输入你需要设置的用户名";
            break;
        case 1:
           [self.textField setHidden:YES];
            [self creatSegment];
            
            break;
        case 2:
            
            self.textField.text = self.phone;
            self.textField.placeholder = @"请输入你电话";

            break;
        case 3:
            
            self.textField.text = self.email;
            self.textField.placeholder = @"请输入你需要设置的Email";
            break;
        
        default:
            break;
    }

}
-(void)creatSegment
{
    UISegmentedControl * segment = [[UISegmentedControl alloc]initWithItems:@[@"男",@"女"]];
    segment.frame = CGRectMake(30, 75, k_width/2, 40);
    NSLog(@"%d",self.sex);
    segment.selectedSegmentIndex = self.sex;
    [segment addTarget:self action:@selector(getSex:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];

}
-(void)getSex:(UISegmentedControl *)sender
{
    
    self.sex = sender.selectedSegmentIndex;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createNavBar
{
    UIImageView * navImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, k_width, 64)];
    
    navImgView.backgroundColor = [UIColor whiteColor];
    navImgView.userInteractionEnabled = YES;
    [self.view addSubview:navImgView];
    UILabel* titlebel = [[UILabel alloc]initWithFrame:CGRectMake(100, 20, k_width-200, 44)];
    
    titlebel.text = @"修改信息";
    
    titlebel.textColor = [UIColor blackColor];
    titlebel.textAlignment = NSTextAlignmentCenter;
    [navImgView addSubview:titlebel];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 27, 80, 40);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_btn_back_pressed@2x"] forState:0];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navImgView addSubview:backBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(k_width-70, 27, 60, 30);
    //saveBtn.backgroundColor = [UIColor redColor];
    [saveBtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [saveBtn setTitle:@"保存" forState:0];
    
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navImgView addSubview:saveBtn];
    
}
-(void)backBtnClick
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)saveBtnClick
{
    [self.view endEditing:YES];
    NSString * key;
    NSString * value;
    if (self.index == 0) {
        key = @"nickName";
        value = self.textField.text;
    }if (self.index == 1) {
        key = @"sex";
        value = [NSString stringWithFormat:@"%d",self.sex];
    }if (self.index == 2) {
        key = @"phone";
        value = self.textField.text;
    }if (self.index == 3) {
        key = @"email";
        value = self.textField.text;
    }
    [self getOffesetUTCTimeSOAPUid:self.uid Key:key Value:value];

    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)getOffesetUTCTimeSOAPUid:(NSString*)uid Key:(NSString *)key Value:(NSString *)value
{
    recordResults = NO;
    //封装soap请求消息
    NSLog(@"\n");
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<userupdate xmlns=\"http://impl.webservice.paile.com\">\n"
                             
                             
                             "<uid>%@</uid>\n"
                             "<key_>%@</key_>\n"
                             "<value_>%@</value_>\n"
                             
                             "</userupdate>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",uid,key,value
                             ];
    NSLog(@"%@",soapMessage);
    //请求发送到的路径
    NSURL *url = [NSURL URLWithString:@"http://www.imapedia.com/services/UserLoginService?wsdl"];
    
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
     NSLog(@"The:%@",theXML);
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
    
    NSData * data = [JsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * alldic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
    if ([alldic[@"code"] isEqualToString:@"000"]) {
        NSLog(@"修改成功");
    }

    
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

- (IBAction)textfiledChange:(id)sender {
}
@end
