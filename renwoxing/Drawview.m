

#import "Drawview.h"

@implementation Drawview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect
{
    
    
    //NSInteger width = [UIScreen mainScreen].bounds.size.width/6;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    //UIFont * font = [UIFont boldSystemFontOfSize:15.0];
    //[@"画圆：" drawInRect:CGRectMake(10, 20, 80, 20) withFont:font];
    //[@"画扇形和椭圆：" drawInRect:CGRectMake(10, 160, 110, 20) withFont:font];
    CGContextSetRGBStrokeColor(context,0,0,0,0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    //    CGContextAddArc(context,rect.size.width/2 , rect.size.height/2, rect.size.height/2, 0, 2*M_PI, 0);
    //    //CGContextAddArc(context, 100, 20, 15, 0, 2*M_PI, 0); //添加一个圆
    //    CGContextDrawPath(context, kCGPathStroke);
    
    
    UIColor * aColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    //以  为半径围绕圆心画指定角度扇形
    
    
    
    
    CGContextMoveToPoint(context, rect.size.height/2, rect.size.height/2);
    CGContextAddArc(context,rect.size.height/2, rect.size.height/2, self.Proportion, -60 * M_PI / 180 , -120* M_PI / 180, 1);
    
    //CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
    
    
    
}




@end
