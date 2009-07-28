#import <Foundation/Foundation.h>

@interface SpinnerWithText : UIView {
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
  NSObject *target;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;
@property (nonatomic, retain) NSObject *target;

- (void)showTheSpinner:(NSString *)text;
- (void)hideTheSpinner:(NSString *)text;
- (void)displayMore;
+ (NSString *)checkingNewString;

@end
