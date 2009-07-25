#import <UIKit/UIKit.h>
#import "SpinnerWithText.h"

@interface ComposeYamController : UIViewController <UITextViewDelegate> {
  UITextView *input;
  SpinnerWithText *topSpinner;
}

@property (nonatomic,retain) UITextView *input;
@property (nonatomic,retain) SpinnerWithText *topSpinner;

- (void)sendYam;

@end
