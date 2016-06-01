
#import <UIKit/UIKit.h>
#import "LeftTableViewController.h"
@interface ChangeViewController : UIViewController
{
    
    NSMutableData *webData;
    NSMutableString *soapResults;
    BOOL recordResults;
}

@property (nonatomic,assign) int index;
@property (nonatomic,strong) NSString * User;
@property (nonatomic,assign) NSInteger  sex;
@property (nonatomic,strong)NSString * uid;
@property (nonatomic,strong) NSString * phone;
@property (nonatomic,strong) NSString * email;
- (IBAction)textfiledChange:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
