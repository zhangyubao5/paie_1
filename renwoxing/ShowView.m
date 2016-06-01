

#import "ShowView.h"

@implementation ShowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)gotoMuseum:(UIButton *)sender {
    
    
}

+(ShowView*)instanceTextView
{
    
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"View" owner:nil options:nil];
    return [nibView objectAtIndex:0];
    
    
}
@end
