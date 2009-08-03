
#import "ToolbarWithText.h"

@implementation ToolbarWithText

@synthesize spinner;
@synthesize displayText;
@synthesize target;
@synthesize spinnerButton;
@synthesize flexItem;
@synthesize theBar;

- (id)initWithFrame:(CGRect)frame target:(NSObject *)theTarget {
  if (self = [super initWithFrame:frame]) {
    self.target = theTarget;
    
    self.theBar = [[UIToolbar alloc] initWithFrame:frame];
    
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
    
    self.flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];

    NSMutableArray *items = [NSMutableArray arrayWithObjects: self.flexItem, custom, self.flexItem, nil];
    [self.theBar setItems:items animated:NO];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 34, 320, 1)];
    [line setBackgroundColor:[UIColor blackColor]];
    
    [self addSubview:self.theBar];
    [self addSubview:line];
  }
  
  return self;
}

- (void)displayLoadingCache {
  self.displayText.text = @"Loading messages from cache...";
}

- (void)displayCheckingNew {
  self.displayText.text = @"Contacting yammer.com...";
}

- (void)setText:(NSString *)text {
  self.displayText.text = text;
}

- (void)setTextToCurrentTime {
  self.displayText.text = @"333";
}

- (void)replaceFlexWithSpinner {
  NSMutableArray *tempItems = [self.theBar.items mutableCopy];
  [tempItems replaceObjectAtIndex:0 withObject:self.spinnerButton];
  [self.theBar setItems:tempItems animated:false];
  [self.spinner startAnimating];
  [tempItems release];
}

- (void)replaceSpinnerWithFlex {
  NSMutableArray *tempItems = [self.theBar.items mutableCopy];
  [tempItems replaceObjectAtIndex:0 withObject:self.flexItem];
  [self.theBar setItems:tempItems animated:false];
  [tempItems release];
}

- (void)dealloc {
  [spinner release];
  [target release];
  [spinnerButton release];
  [flexItem release];
  [theBar release];
  [super dealloc];
}

@end
