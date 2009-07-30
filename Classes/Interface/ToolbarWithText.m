
#import "ToolbarWithText.h"

@implementation ToolbarWithText

@synthesize spinner;
@synthesize displayText;
@synthesize target;

- (id)initWithFrame:(CGRect)frame parent:(NSObject *)list {
  if (self = [super initWithFrame:frame]) {
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:list
                                                                           action:@selector(refresh)];
    refresh.style = UIBarButtonItemStyleBordered;
       
    UIView *statusAndSpinner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 218, 30)];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 4, 20, 20)];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.displayText = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    self.displayText.textColor = [UIColor whiteColor];
    self.displayText.textAlignment = UITextAlignmentCenter;
    self.displayText.font = [UIFont systemFontOfSize:12];
    self.displayText.backgroundColor = [UIColor clearColor];
    [statusAndSpinner addSubview:self.displayText];
        
    UIBarButtonItem *custom = [[UIBarButtonItem alloc] initWithCustomView:statusAndSpinner];
    

    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:list
                                                                             action:@selector(compose)];
    compose.style = UIBarButtonItemStyleBordered;        
    NSMutableArray *items = [NSMutableArray arrayWithObjects: refresh, custom, compose, nil];
    [self setItems:items animated:NO];        
  }
  
  return self;
}

- (void)displayCheckingNew {
  self.displayText.text = @"Checking for new messages...";
}

  
- (void)dealloc {
  [spinner release];
  [target release];
  [super dealloc];
}

@end
