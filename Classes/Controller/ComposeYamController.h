#import <UIKit/UIKit.h>


@interface ComposeYamController : UIViewController <UITextViewDelegate> {
  UITextView *input;
}

@property (nonatomic,retain) UITextView *input;

- (void)sendYam;

@end
