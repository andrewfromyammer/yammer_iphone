#import <Foundation/Foundation.h>

@interface SpinnerWithText : UIView {
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
  NSObject *target;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;
@property (nonatomic, retain) NSObject *target;

- (void)showTheSpinner;
- (void)hideTheSpinner;  
- (void)displayLoadingCache;
- (void)displayCheckingNew;
- (void)displayLoading;
- (void)setText:(NSString *)text;

@end
