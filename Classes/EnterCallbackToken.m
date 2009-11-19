#import "EnterCallbackToken.h"
#import "OAuthGateway.h"
#import "APIGateway.h"
#import "YammerAppDelegate.h"

@implementation EnterCallbackToken

@synthesize input = _input, intro = _intro;

- (void)loadView {
  [super loadView];
  self.title = @"Code";
  
  self.intro = [[UILabel alloc] initWithFrame:CGRectMake(10,10,300,60)];
  self.intro.numberOfLines = 0;
  self.intro.text = @"You were given a 4 digit code when you authorized this application.  Please enter it now:";
  
  self.input = [[UITextField alloc] initWithFrame:CGRectMake(70,90,140,40)];
  _input.font = [UIFont systemFontOfSize:36];
  _input.backgroundColor = [UIColor lightGrayColor];
  
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Cancel";
  temporaryBarButtonItem.target = self;
  temporaryBarButtonItem.action = @selector(cancel);
  self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];

  temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Submit";
  temporaryBarButtonItem.target = self;
  temporaryBarButtonItem.action = @selector(submit);
  self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
  
  [self.view addSubview:_intro];
  [self.view addSubview:_input];  
}

- (void)viewDidLoad {
  [super viewDidLoad];

  
  [_input becomeFirstResponder];
}

- (void)cancel {
  [OAuthGateway logout];
}

- (void)submit {
  [_input setEnabled:NO];
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  if ([OAuthGateway getAccessToken:nil callbackToken:_input.text] && [APIGateway usersCurrent:@"silent"] && [APIGateway networksCurrent:@"silent"]) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [yam setupNavigator];
  }
  else {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [OAuthGateway logout];
  }
}

- (void)dealloc {
  TT_RELEASE_SAFELY(_input);
  TT_RELEASE_SAFELY(_intro);
  [super dealloc];
}

@end
