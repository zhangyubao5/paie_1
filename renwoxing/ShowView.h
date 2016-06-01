

#import <UIKit/UIKit.h>
#import "DetaileViewController.h"
@interface ShowView : UIView
@property (strong, nonatomic) IBOutlet UIView *showMainview;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UILabel *From;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollVi;
- (IBAction)gotoMuseum:(UIButton *)sender;
@property (strong,nonatomic) NSString * Id;
+(ShowView*)instanceTextView;
@end
