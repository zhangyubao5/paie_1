
#import "ShopShowView.h"

@implementation ShopShowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+(ShopShowView*)instanceTextView
{
    
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"ShopShowView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
    
    
}

@end
