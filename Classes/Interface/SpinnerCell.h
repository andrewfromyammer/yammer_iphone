#import <Foundation/Foundation.h>

@interface SpinnerCell : UITableViewCell {
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;

- (void)showSpinner;
- (void)hideSpinner;
- (void)displayMore;
- (void)displayCheckNew;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier spinRect:(CGRect)spinRect textRect:(CGRect)textRect;

@end
