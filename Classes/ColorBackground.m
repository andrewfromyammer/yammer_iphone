
#import "ColorBackground.h"

@implementation ColorBackground

@synthesize fillColor;

- (BOOL) isOpaque {
  return NO;
}

- (id)initWithColor:(UIColor*)color {
  if (self = [super initWithFrame:CGRectZero]) {
    self.fillColor = color;
  }
  return self;
}

-(void)drawRect:(CGRect)rect 
{
  // Drawing code
  
  CGContextRef c = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(c, [fillColor CGColor]);
  
  CGContextFillRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height));
}

- (void)dealloc {
  [fillColor release];
  [super dealloc];
}


@end
