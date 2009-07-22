#import <Foundation/Foundation.h>

@interface SpinnerCell : UITableViewCell {
  UIActivityIndicatorView *spinner;
  UILabel *displayText;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *displayText;

@end
