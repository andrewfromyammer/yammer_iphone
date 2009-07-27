
#import "SpinnerWithText.h"

@implementation SpinnerWithText

@synthesize spinner;
@synthesize displayText;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 4, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(30, 4, 270, 20)];
    self.displayText.textColor = [UIColor blueColor];
    self.displayText.textAlignment = UITextAlignmentCenter;
    self.displayText.font = [UIFont systemFontOfSize:12];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
    [line setBackgroundColor:[UIColor lightGrayColor]];

		[self addSubview:line];    
		[self addSubview:self.displayText];
    [self.displayText release];
  }
  
  return self;
}

- (void)showTheSpinner:(NSString *)text {
  [self.displayText setText:text];
  [self addSubview:self.spinner];
  [spinner startAnimating];
}

- (void)hideTheSpinner:(NSString *)text {
  [self.displayText setText:text];
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
