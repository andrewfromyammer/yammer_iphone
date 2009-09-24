
#import <Three20/Three20.h>

@interface ColorBackground : UIView {
  UIColor *fillColor;
}

@property(nonatomic, retain) UIColor *fillColor;

- (id)initWithColor:(UIColor*)color;

@end