#import <UIKit/UIKit.h>
#import "SpinnerWithText.h"

@interface ComposeYamController : UIViewController <UITextViewDelegate> {
  UITextView *input;
  SpinnerWithText *topSpinner;
  SpinnerWithText *previousSpinner;
}

@property (nonatomic,retain) UITextView *input;
@property (nonatomic,retain) SpinnerWithText *topSpinner;
@property (nonatomic,retain) SpinnerWithText *previousSpinner;

- (void)sendYam;
- (id)initWithSpinner:(SpinnerWithText *)spinner;
- (void)sendUpdate:(NSString *)text;

@end
