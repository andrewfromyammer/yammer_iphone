#import <Foundation/Foundation.h>

@interface ToolbarWithText : UIView {
  UIToolbar *theBar;
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
  NSObject *target;
  UIBarButtonItem *spinnerButton;
  UIBarButtonItem *flexItem;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;
@property (nonatomic, retain) NSObject *target;
@property (nonatomic, retain) UIBarButtonItem *spinnerButton;
@property (nonatomic, retain) UIBarButtonItem *flexItem;
@property (nonatomic, retain) UIToolbar *theBar;

- (id)initWithFrame:(CGRect)frame target:(NSObject *)theTarget;

- (void)displayCheckingNew;
- (void)replaceFlexWithSpinner;
- (void)replaceSpinnerWithFlex;
- (void)setText:(NSString *)text;
- (void)setTextToCurrentTime;

@end
