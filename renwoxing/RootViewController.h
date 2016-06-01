

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Drawview.h"
#import "DrawPoint.h"
#import "SearchModel.h"
#import "ShowView.h"
#import "ShopShowView.h"
#import "DefinitionButton.h"
#import "DetaileViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "OpenGLView.h"
#import "AFNetworking.h"
#import "ZipArchive.h"
#import "CYDataBase.h"
#import "HQModel.h"
@class  LeftViewController;
@interface RootViewController : UIViewController
<CLLocationManagerDelegate,AMapSearchDelegate> {
    Drawview *arrow;
    
    CLLocationManager *locManager;
    NSMutableData *webData;
    NSMutableString *soapResults;
    BOOL recordResults;
}
@property (nonatomic,strong) DrawPoint * drawpoint;
@property (strong,nonatomic) CLLocationManager *locManager;
@property (strong,nonatomic) UILabel *angel;
@property (strong,nonatomic) NSMutableArray * data ;
@property (strong,nonatomic) NSMutableArray * pointData;//点位置数组

@property (assign)float azimuth_angle;
@property (nonatomic,strong)ShowView * showview;
@property (nonatomic,strong)ShopShowView * shopShowView;
@property (strong, nonatomic)  UILabel *connextLabel;
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight  [UIScreen mainScreen].bounds.size.height
@property (nonatomic,strong)AMapPOIAroundSearchRequest *request;

@property (nonatomic,strong)AVCaptureSession  *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* liveViewLayer;
@property (nonatomic,strong) NSString * Hid;
@property (nonatomic,assign)CGAffineTransform transform;
@property (nonatomic,assign)CGPoint beganPoint;//touch 始末位置
@property (nonatomic,assign)CGPoint endPoint;
@property (nonatomic,assign)float From;
@property (nonatomic,assign)float curentRadius;//目前半径
@property (nonatomic,strong)NSString * zipURl;
@property(nonatomic, strong) OpenGLView *glView;
- (id)initWithCenterVC:(RootViewController *)centerVC  leftVC:(LeftViewController *)leftVC;


@end
