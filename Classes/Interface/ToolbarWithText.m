
#import "ToolbarWithText.h"

@implementation ToolbarWithText

@synthesize spinner;
@synthesize displayText;
@synthesize target;
@synthesize spinnerButton;
@synthesize refreshButton;

- (id)initWithFrame:(CGRect)frame target:(NSObject *)theTarget {
  if (self = [super initWithFrame:frame]) {
    self.target = theTarget;
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self.target
                                                                             action:@selector(refresh)];
    self.refreshButton.style = UIBarButtonItemStyleBordered;

    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 3, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    wrapper.backgroundColor = [UIColor clearColor];
    [wrapper addSubview:self.spinner];
    self.spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:wrapper];
    
    
    UIView *statusAndSpinner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 218, 30)];
        
    self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    self.displayText.textColor = [UIColor whiteColor];
    self.displayText.textAlignment = UITextAlignmentCenter;
    self.displayText.font = [UIFont systemFontOfSize:12];
    self.displayText.backgroundColor = [UIColor clearColor];
    [statusAndSpinner addSubview:self.displayText];
        
    UIBarButtonItem *custom = [[UIBarButtonItem alloc] initWithCustomView:statusAndSpinner];
    

    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:self.target
                                                                             action:@selector(compose)];
    compose.style = UIBarButtonItemStyleBordered;
    NSMutableArray *items = [NSMutableArray arrayWithObjects: self.refreshButton, custom, compose, nil];
    [self setItems:items animated:NO];        
  }
  
  return self;
}

- (void)displayCheckingNew {
  self.displayText.text = @"Checking for new messages...";
}

- (void)setText:(NSString *)text {
  self.displayText.text = text;
}

- (void)setTextToCurrentTime {
  self.displayText.text = @"333";
}

- (void)replaceRefreshWithSpinner {
  NSMutableArray *tempItems = [self.items mutableCopy];
  [tempItems replaceObjectAtIndex:0 withObject:self.spinnerButton];
  [self setItems:tempItems animated:false];
  [self.spinner startAnimating];
  [tempItems release];
}

- (void)replaceSpinnerWithRefresh {
  NSMutableArray *tempItems = [self.items mutableCopy];
  [tempItems replaceObjectAtIndex:0 withObject:self.refreshButton];
  [self setItems:tempItems animated:false];
  [tempItems release];
}

  
- (void)dealloc {
  [spinner release];
  [target release];
  [spinnerButton release];
  [refreshButton release];
  [super dealloc];
}

@end
