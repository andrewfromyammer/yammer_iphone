
#import "SpinnerCell.h"

@implementation SpinnerCell

@synthesize spinner;
@synthesize displayText;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    UIView *myContentView = self.contentView;
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 12, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, 200, 20)];
    self.displayText.textColor = [UIColor blueColor];

		[myContentView addSubview:self.spinner];
		[myContentView addSubview:self.displayText];
    [self.spinner release];
    [self.displayText release];
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
