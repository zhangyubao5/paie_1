

#import "LeftTableViewController.h"
#import "RootViewController.h"
#import "LeftCell.h"

@interface LeftTableViewController ()<NSURLConnectionDataDelegate>

@property(nonatomic,retain)NSArray *name;
@property(nonatomic, assign) NSInteger previousRow;


@property(nonatomic,retain)NSArray *arrName;
@property(nonatomic,retain)NSArray *arrImagehead;
@property(nonatomic,retain)NSArray *arrImageFoot;

@end

@implementation LeftTableViewController


-(UILabel *)labName
{
    if (_labName == nil) {
        _labName = [[UILabel alloc] initWithFrame:CGRectMake(40, 75, 140, 30)];
        _labName.font = [UIFont systemFontOfSize:18];
        _labName.textColor = [UIColor whiteColor];
    }
    return _labName;
}
-(UILabel *)labCom
{
    if (_labCom == nil) {
       _labCom = [[UILabel alloc] initWithFrame:CGRectMake(40, 110, 140, 20)];
        _labCom.textColor = [UIColor whiteColor];
    }
    return _labCom;
}
-(id)initWithString:(NSArray *)name
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _name = name;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString] ;
    NSLog(@"手机序列号: %@",identifierNumber);
    [self getOffesetUTCTimeSOAP:identifierNumber];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString] ;
//    NSLog(@"手机序列号: %@",identifierNumber);
//    [self getOffesetUTCTimeSOAP:identifierNumber];
    
    _arrName = @[@"用户名",@"性别",@"电话",@"Email",@"选择博物馆"];
      _arrImageFoot = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"left_bar_icon@2x.png"],
                                                     [UIImage imageNamed:@"left_bar_icon@2x.png"],
                                                     [UIImage imageNamed:@"left_bar_icon@2x.png"],
                                                     [UIImage imageNamed:@"left_bar_icon@2x.png"],[UIImage imageNamed:@"left_bar_icon@2x.png"],nil];

    
    
    
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
                             "<userAutoRegist xmlns=\"http://impl.webservice.paile.com\">\n"
                             
                             
                             "<uid>%@</uid>\n"
                             
                             "</userAutoRegist>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",data
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
   // NSLog(@"The:%@",theXML);
    
    
    NSArray * array1 = [theXML componentsSeparatedByString:@">{"];
    NSArray * array2 = [array1[1] componentsSeparatedByString:@"}<"];
    NSString * JsonData = [NSString stringWithFormat:@"{%@}",array2[0]];
    NSLog(@"~~~~~%@~~~~~~~~~",JsonData);
    [self AnalysisJson:JsonData];
}
-(void)AnalysisJson:(NSString *)string
{
    
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * alldic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error ];
    if (error) {
        NSLog(@"解析失败！===%@",error);
    }
    self.labName.text = alldic[@"content"][@"nickName"];
    self.labCom.text = alldic[@"content"][@"uId"];
    self.uid =alldic[@"content"][@"uId"];
    self.sex =[alldic[@"content"][@"sex"] integerValue];
    self.User = alldic[@"content"][@"nickName"];
    self.phone = alldic[@"content"][@"phone"];
    self.email =alldic[@"content"][@"email"];

    
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 260, 130)];
    view.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 30, 60, 60)];
    image.layer.cornerRadius = 30;
    image.clipsToBounds = YES;
    image.image = [UIImage imageNamed:@"user_default"];
    [view addSubview:image];
    
    [view addSubview:self.labName];
    [view addSubview: self.labCom];
    UIView * stuta  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 20)];
    stuta.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:stuta];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 568-50, 260, 50)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 250, 40)];
    lab.textAlignment = 1;
    lab.text = @"湖南拍晓科技有限公司";
    [view addSubview:lab];
       return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _name.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LeftCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSArray *objs = [bundle loadNibNamed:@"LeftCell" owner:nil options:nil];
        cell =[objs lastObject];
        
    }
    NSLog(@"%@",_arrName[indexPath.row]);
    cell.labText.text = _arrName[indexPath.row];
   // cell.imageHead.image = _arrImagehead[indexPath.row];
    cell.imageFoot.image = _arrImageFoot[indexPath.row];

    return cell;

    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChangeViewController * ChangeVC = [[ChangeViewController alloc]init];
    GetMuseumViewController * MuseVC = [[GetMuseumViewController alloc]init];
    
         NSLog(@"%d",indexPath.row);
   
        if (indexPath.row==0) {
             NSLog(@"%d",indexPath.row);
            ChangeVC.User = self.User;
            ChangeVC.uid = self.uid;
            ChangeVC.index = indexPath.row;
            self.previousRow = indexPath.row;
            [self presentViewController:ChangeVC animated:YES completion:^{
                
            }];
           
        }else if (indexPath.row==1)
        {
            ChangeVC.sex = self.sex;
            NSLog(@"%d",indexPath.row);
            ChangeVC.uid = self.uid;
            ChangeVC.index = indexPath.row;
            self.previousRow = indexPath.row;
            [self presentViewController:ChangeVC animated:YES completion:^{
                
            }];
            
        }else if(indexPath.row==2)
        {
            ChangeVC.phone = self.phone;
            NSLog(@"%d",indexPath.row);
            ChangeVC.uid = self.uid;
            ChangeVC.index = indexPath.row;
            self.previousRow = indexPath.row;
            [self presentViewController:ChangeVC animated:YES completion:^{
                
            }];
            
        }else if (indexPath.row==3)
        {
            ChangeVC.email = self.email;
             NSLog(@"%d",indexPath.row);
            ChangeVC.uid = self.uid;
            ChangeVC.index = indexPath.row;
            self.previousRow = indexPath.row;
            [self presentViewController:ChangeVC animated:YES completion:^{
                
            }];
           
        }else if (indexPath.row==4)
        {
            NSLog(@"%d",indexPath.row);
            
            [self presentViewController:MuseVC animated:YES completion:^{
                
            }];
        }
    
    
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
