

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RectangleRectanglView.h"
#import "IntroductionViewController.h"
@interface DetaileViewController : UIViewController<UIGestureRecognizerDelegate>
{
    NSMutableString *soapResults;
    BOOL recordResults;

}
@property (strong, nonatomic) IBOutlet UIButton *snapButton;
- (IBAction)backButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *liveView;
@property (strong, nonatomic) IBOutlet UIView *butView;
- (IBAction)snap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *cutimageview;

@property (nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;
- (IBAction)Compared:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *CompareButton;
@property (nonatomic,strong)NSString * SID;
@property (nonatomic,strong)NSString * HID;
@property (nonatomic,strong)NSString* lat;
@property (nonatomic,strong)NSString* lon;//经纬度
@property (nonatomic,strong)NSMutableData *webData;//调用接口返回的data
@property (nonatomic,strong)RectangleRectanglView * rectanglView;//
@property (nonatomic,strong)UIImage * cutImage;//截下来的image
@property (retain,nonatomic) NSString * base64;//
@property (nonatomic,strong)UIImageView * preView;//拍照后展示图片的imageView
@property (nonatomic,strong)AVCaptureSession  *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property(nonatomic,assign)CGFloat beginGestureScale;//焦距始末比例
@property(nonatomic,assign)CGFloat effectiveScale;

/*获取时间*/
@property(nonatomic,assign)UInt64 Upmsecond1;
@property(nonatomic,assign)UInt64 Upmsecond2;
@end
