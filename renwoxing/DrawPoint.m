
#import "DrawPoint.h"

@implementation DrawPoint

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(NSMutableArray*)datapoint
{
    if (_datapoint== nil) {
        _datapoint = [[NSMutableArray alloc]init];
        
    }
    return _datapoint;
}
-(void)drawRect:(CGRect)rect
{
   // NSLog(@"%@",NSStringFromCGRect(rect));
    
    int i ;
    for (i = 0; i<self.datapoint.count; i++) {
        
        
        
        CGPoint one = CGPointFromString(self.datapoint[i]);
        
        
     //com.impedia.pailiao
       
    self.cir1 = [UIBezierPath bezierPathWithArcCenter:one
                                                            radius:3
                                                        startAngle:0
                                                          endAngle:2 * M_PI
                                                         clockwise:1];
        
        UIColor *strokeColor = [UIColor whiteColor];
      [strokeColor set];
        [self.cir1 fill];

    }
    
}
@end
