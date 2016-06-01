
#import "RectangleRectanglView.h"

@interface RectangleRectanglView ()
@property (nonatomic,assign)CGPoint currentPoint;
@property (nonatomic,strong)NSMutableArray * pathArr;

@property (nonatomic,strong)UIBezierPath * currentpath;


@property (nonatomic, strong) UIColor* currentColor;

@property (nonatomic,assign)CGPoint one;
@property (nonatomic,assign)CGPoint two;


@property (nonatomic,assign)BOOL onOne;
@property (nonatomic,assign)BOOL onTwo;
@property (nonatomic,assign)BOOL onDraw;
@end

@implementation RectangleRectanglView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(NSMutableArray *)pathArr
{
    if (_pathArr == nil) {
        _pathArr = [NSMutableArray new];
    }
    return _pathArr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)selectAllpictures
{


}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _beganPoint = CGPointMake(10, 50);
        _endPoint = CGPointMake(frame.size.width -20, ([UIScreen mainScreen].bounds.size.height-64)/2+44 );
        _one.x = 15;
        _one.y = 60;
        _two.x =frame.size.width -15;
        _two.y = ([UIScreen mainScreen].bounds.size.height-64)/2+44-15;
        [self drawRectangle];
          }
    return self;
}

-(void)didMoveToSuperview
{
    

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _onDraw = 0;
    _one = CGPointZero;
    _two = CGPointZero;
    //[_pathArr removeAllObjects];
    //[self setNeedsDisplay];
    UIBezierPath * path = [UIBezierPath bezierPath];
    [self.pathArr addObject:path];
    _currentpath = path;
    
    //设置划线颜色
    //_currentColor = [UIColor greenColor];
    _beganPoint = [touches.anyObject locationInView:self ];
    //获取当前点
    self.currentPoint = [touches.anyObject locationInView:self ];
     [self drawLineTouchBegin];

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _currentPoint = [touches.anyObject locationInView:self];
    
    [self drawLineTouchMove];

    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (CGSizeEqualToSize(_currentpath.bounds.size, CGSizeZero)) {
        [self.pathArr removeObject:self.currentpath];
        
    }
    _endPoint = [touches.anyObject locationInView:self ];

    [self drawLineTouchEnd];
    
}
-(void)drawRect:(CGRect)rect
{
    for (int i = 0; i < self.pathArr.count; i++) {
        UIBezierPath* path = _pathArr[i];
        [path setLineWidth:5];
    }
    [self drawRectanglePath];
    
    
}


//划线---开始触摸
- (void)drawLineTouchBegin
{
    if (CGPointEqualToPoint(_one, CGPointZero)) {
        _one = _currentPoint;
        _two = _one;
    }
    if (_onDraw) {
       
        _onOne = [self selectPoint:_currentPoint OnPoint:_one];
        _onTwo = [self selectPoint:_currentPoint OnPoint:_two];
       // _onThree = [self selectPoint:_currentPoint OnPoint:_three];
    }
}

//画线--移动
- (void)drawLineTouchMove
{
    if (!_onDraw) {
        _two = _currentPoint;
    }
    else {
        _one = _onOne ? _currentPoint : _one;
        _two = _onTwo ? _currentPoint : _two;
    }
}
- (void)drawLineTouchEnd
{
    if (!CGPointEqualToPoint(_two, _one)) {
        _onDraw = 1;
    }
}
#pragma mark-------------------画矩形--------------
- (UIBezierPath*)drawRectangle
{
    if (_two.y < 44) {
        _two.y = 45;
    }
    if (_two.y > ([UIScreen mainScreen].bounds.size.height-64)/2+44) {
        _two.y =([UIScreen mainScreen].bounds.size.height-64)/2+44;
    }
    CGRect rect = CGRectMake(_one.x, _one.y, _two.x - _one.x, _two.y - _one.y);
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [path setLineWidth:3];
    UIColor *strokeColor = [UIColor greenColor];
    [strokeColor set];
    return path;
}
- (void)drawRectanglePath
{
    UIBezierPath* cir1 = [UIBezierPath bezierPathWithArcCenter:_one
                                                        radius:0
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:1];
    [cir1 fill];
    UIBezierPath* cir2 = [UIBezierPath bezierPathWithArcCenter:_two
                                                        radius:0
                                                    startAngle:0
                                                      endAngle:2 * M_PI
                                                     clockwise:1];
    [cir2 fill];
    
    [[self drawRectangle] stroke];
    
}

//选择拖动点
- (BOOL)selectPoint:(CGPoint)Point OnPoint:(CGPoint)center
{
    CGRect rect = CGRectMake(center.x - 5, center.y - 5, 10, 10);
    return CGRectContainsPoint(rect, Point);
}
@end
