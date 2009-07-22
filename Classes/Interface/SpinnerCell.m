
#import "SpinnerCell.h"

@implementation SpinnerCell

@synthesize spinner;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    UIView *myContentView = self.contentView;
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 12, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

		[myContentView addSubview:self.spinner];
    [self.spinner release];
  }
  
  return self;
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
	
}
  
- (void)dealloc {
  [spinner release];
  [super dealloc];
}

@end
