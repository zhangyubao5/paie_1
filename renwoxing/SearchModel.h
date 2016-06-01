
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SearchModel : NSObject

@property (nonatomic,strong)NSString * name;
@property (nonatomic,assign) float lon;
@property (nonatomic,assign)float  lat;
@property (nonatomic,strong)NSString * Content;//内容--地址
@property (nonatomic,strong)NSNumber * contentHeight;

@property (nonatomic,strong)NSString * Hid;
@property (nonatomic,strong)NSString * tel;
@property (nonatomic, assign) NSInteger  distance;

@end
