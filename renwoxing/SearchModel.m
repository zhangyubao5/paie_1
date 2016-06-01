

#import "SearchModel.h"

@implementation SearchModel
-(void)setContent:(NSString *)Content
{
    _Content = Content;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    
    CGRect rect = [Content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-55, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    _contentHeight =  @(rect.size.height);


}
@end
