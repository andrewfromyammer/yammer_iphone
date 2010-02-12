#import "MainTabBar.h"
#import "FeedMessageList.h"
#import "LocalStorage.h"
#import "FeedList.h"
#import "DirectoryList.h"
#import "Settings.h"
#import "ComposeMessage.h"
#import "OAuthGateway.h"
#import "YammerAppDelegate.h"

@implementation MainTabBar

- (id)init {
  if (self = [super init]) {
    YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.title = yammer.network_name;
    self.delegate = self;
    [NSThread detachNewThreadSelector:@selector(addComposeThread) toTarget:self withObject:nil];    
  }
  return self;
}

- (void)addComposeThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  sleep(2);
  if ([self selectedIndex] == 0)
    [self performSelectorOnMainThread:@selector(addCompose) withObject:nil waitUntilDone:NO];  
  [autoreleasepool release];
}

- (void)addCompose {
  UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(compose)];
  self.navigationItem.rightBarButtonItem = compose;    
}

- (void)addRefresh {
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refreshDirectoryTab)];
  self.navigationItem.rightBarButtonItem = refresh;
}

- (void)addLogout {
  UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
  self.navigationItem.rightBarButtonItem = logout;    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
  if ([tabBarController selectedIndex] == 0) {
    [self addCompose];
  } else if ([tabBarController selectedIndex] == 3) {
    [self addRefresh];
  } else if ([tabBarController selectedIndex] == 4) {
    [self addLogout];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)logout {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                  message:@"Click the confirm button below to log out from this account and exit the Yammer Application." delegate:self 
                                        cancelButtonTitle:nil otherButtonTitles: @"Cancel", @"Confirm", nil];
  [alert show];
  [alert release];  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1)
    [OAuthGateway logout];
}


- (void)compose {
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  [meta setObject:@"To: My Colleagues" forKey:@"display"];
  [self presentModalViewController:[ComposeMessage getNav:meta] animated:YES];
}

- (void)refreshDirectoryTab {
  TTNavigator* navigator = [TTNavigator navigator];
  DirectoryList* list = (DirectoryList*)[navigator visibleViewController];
  [list refreshDirectory];
}

+ (UIColor *)yammerGray {
  return [UIColor colorWithRed:0.27 green:0.34 blue:0.39 alpha:1.0];
}

- (void)setupView:(UIViewController *)view title:(NSString *)title image:(NSString *)image {
  view.title = title;
  view.tabBarItem.image = [UIImage imageNamed:image];  
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Back";
  view.navigationItem.backBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
}

- (void)loadView {
  [super loadView];
  
  NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:5];
  
  FeedMessageList *theView = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getFeedInfo] refresh:YES compose:NO thread:NO] autorelease];
  [self setupView:theView title:@"My Feed" image:@"home.png"];
  [localViewControllersArray addObject:theView];
  
  FeedMessageList *received = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getReceivedInfo] refresh:YES compose:NO thread:NO] autorelease];
  [self setupView:received title:@"Received" image:@"received.png"];
  [localViewControllersArray addObject:received];
  
  FeedList* feedView = [[[FeedList alloc] init] autorelease];
  [self setupView:feedView title:@"Feeds" image:@"feeds.png"];
  [localViewControllersArray addObject:feedView];
  
  DirectoryList* directory = [[[DirectoryList alloc] init] autorelease];
  [self setupView:directory title:@"Directory" image:@"directory.png"];
  [localViewControllersArray addObject:directory];
  
  Settings *settingsViewController = [[[Settings alloc] init] autorelease];
  [self setupView:settingsViewController title:@"Settings" image:@"settings.png"];
  [localViewControllersArray addObject:settingsViewController];
  
  self.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
  
}

- (void)dealloc {
  self.viewControllers = nil;
  [super dealloc];
}

@end
