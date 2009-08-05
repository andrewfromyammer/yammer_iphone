
#import "SpinnerWithText.h"

@implementation SpinnerWithText

@synthesize spinner;
@synthesize displayText;
@synthesize target;

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 4, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(30, 4, 270, 20)];
    self.displayText.textColor = [UIColor darkGrayColor];
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

- (void)showTheSpinner {
  [self addSubview:self.spinner];
  [spinner startAnimating];
}

- (void)hideTheSpinner {
  [spinner stopAnimating];
  [spinner removeFromSuperview];
}

- (void)displayLoadingCache {
  self.displayText.text = @"Loading messages from cache...";
}

- (void)displayCheckingNew {
  self.displayText.text = @"Contacting yammer.com...";
}

- (void)displayLoading {
  self.displayText.text = @"Loading...";
}

- (void)setText:(NSString *)text {
  self.displayText.text = text;
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
	
}
  
- (void)dealloc {
  [spinner release];
  [target release];
  [super dealloc];
}

@end
