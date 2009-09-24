#import <Three20/Three20.h>

@interface SpinnerViewController : TTViewController {
  UIView *wrapper;
  UIActivityIndicatorView *spinner;
  UILabel *loading;
}

@property (nonatomic,retain) UIView *wrapper;
@property (nonatomic,retain) UIActivityIndicatorView *spinner;
@property (nonatomic,retain) UILabel *loading;

- (void)getData;
- (void)refresh;
- (void)addRefreshButton;
- (void)addComposeButton;

@end
