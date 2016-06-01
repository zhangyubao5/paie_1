

#import "ResultModel.h"

@implementation ResultModel
-(void)setDescriptio:(NSString *)descriptio
{
    _descriptio = descriptio;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    
    CGRect rect = [descriptio boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-55, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    _descriptioheight =  @(rect.size.height);
    
    
}
@end
