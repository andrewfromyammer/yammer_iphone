
#import "SpinnerCell.h"

@implementation SpinnerCell

@synthesize spinner;
@synthesize displayText;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier spinRect:(CGRect)spinRect textRect:(CGRect)textRect {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    UIView *myContentView = self.contentView;
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinRect];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.displayText = [[UILabel alloc] initWithFrame:textRect];
    self.displayText.textColor = [UIColor blueColor];

//		[myContentView addSubview:self.spinner];
		[myContentView addSubview:self.displayText];
    [self.spinner release];
    [self.displayText release];
  }
  
  return self;
}

- (void)showSpinner {
  [self.contentView addSubview:self.spinner];
  [spinner startAnimating];
}

- (void)hideSpinner {
  [spinner stopAnimating];
  [spinner removeFromSuperview];
}

- (void)displayMore {
  [displayText setText:@"        More"];
}

- (void)displayCheckNew {
  [displayText setText:@"Checking for new Yams..."];
}


- (void)layoutSubviews {
  
  [super layoutSubviews];
	
}
  
- (void)dealloc {
  [spinner release];
  [super dealloc];
}

@end
