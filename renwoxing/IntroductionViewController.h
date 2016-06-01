
#import <UIKit/UIKit.h>
#import "ResultModel.h"
#import <AVFoundation/AVSpeechSynthesis.h>

@interface IntroductionViewController : UIViewController
{
    
    NSMutableString *soapResults;
    BOOL recordResults;

}
@property (strong, nonatomic) IBOutlet UIScrollView *imgScroller;
@property (strong, nonatomic) IBOutlet UIScrollView *connextScroller;
@property (strong, nonatomic) IBOutlet UILabel *autherLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)backButtonClick:(UIButton *)sender;

@property (nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;
- (IBAction)ReadingButton:(UIButton *)sender;
@property (nonatomic,strong)UILabel * detail;
@property (nonatomic,strong)UILabel * connextLabel;
@property (nonatomic,strong)NSMutableArray * data;
@property (strong, nonatomic) IBOutlet UIButton *readButton;
@property (nonatomic,strong)NSMutableData *webData;
@property (nonatomic,strong)NSString * sid;
@property (nonatomic,strong)NSString * currentdetail;
@property (nonatomic,strong)AVSpeechSynthesizer *av;
@end
