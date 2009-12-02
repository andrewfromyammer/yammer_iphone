#import "MainTabBar.h"
#import "FeedMessageList.h"
#import "LocalStorage.h"
#import "FeedList.h"
#import "DirectoryList.h"
#import "Settings.h"
#import "ComposeMessage.h"

@implementation MainTabBar

- (id)init {
  if (self = [super init]) {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];    
    self.delegate = self;
    [NSThread detachNewThreadSelector:@selector(addComposeThread) toTarget:self withObject:nil];
  }  
  return self;
}

- (void)addComposeThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  sleep(2);
  [self performSelectorOnMainThread:@selector(addCompose) withObject:nil waitUntilDone:NO];  
  [autoreleasepool release];
}

- (void)addCompose {
  UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(compose)];
  self.navigationItem.rightBarButtonItem = compose;    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
  if ([tabBarController selectedIndex] == 0) {
    [self addCompose];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)compose {
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  [meta setObject:@"To: My Colleagues" forKey:@"display"];
  [self presentModalViewController:[ComposeMessage getNav:meta] animated:YES];
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
  
  FeedMessageList *theView = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getFeedInfo] refresh:YES compose:YES thread:NO] autorelease];
  [self setupView:theView title:@"My Feed" image:@"home.png"];
  [localViewControllersArray addObject:theView];
  
  FeedMessageList *received = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getReceivedInfo] refresh:YES compose:YES thread:NO] autorelease];
  [self setupView:received title:@"Received" image:@"received.png"];
  [localViewControllersArray addObject:received];
  
  FeedList* feedView = [[[FeedList alloc] init] autorelease];
  [self setupView:feedView title:@"Feeds" image:@"feeds.png"];
  [localViewControllersArray addObject:feedView];
  
  DirectoryList* directory = [[[DirectoryList alloc] init] autorelease];
  [self setupView:directory title:@"Directory" image:@"directory.png"];
  [localViewControllersArray addObject:directory];
  
  Settings *settingsViewController = [[Settings alloc] init];
  [self setupView:settingsViewController title:@"Settings" image:@"settings.png"];
  [localViewControllersArray addObject:settingsViewController];
  
  self.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
  
}

@end
