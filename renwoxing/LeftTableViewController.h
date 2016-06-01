

#import <UIKit/UIKit.h>
#import "ChangeViewController.h"
#import "GetMuseumViewController.h"
@interface LeftTableViewController : UITableViewController
{
    
    NSMutableData *webData;
    NSMutableString *soapResults;
    BOOL recordResults;
}
@property (nonatomic,strong)  UILabel *labName;
@property (nonatomic,strong) UILabel *labCom ;

@property (nonatomic,strong)NSString * uid;
@property (nonatomic,strong) NSString * User;
@property (nonatomic,assign) NSInteger  sex;
@property (nonatomic,strong) NSString * phone;
@property (nonatomic,strong) NSString * email;
-(id)initWithString:(NSArray *)name;
- (void)getOffesetUTCTimeSOAP:(NSData*)data;
@end
