
#import <UIKit/UIKit.h>

@interface ShopShowView : UIView
@property (strong, nonatomic) IBOutlet UILabel *titltLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *telLabel;


+(ShopShowView*)instanceTextView;
@end
