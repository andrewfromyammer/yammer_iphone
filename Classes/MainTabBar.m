#import "MainTabBar.h"
#import "FeedMessageList.h"
#import "LocalStorage.h"
#import "FeedList.h"
#import "DirectoryList.h"
#import "SettingsViewController.h"

@implementation MainTabBar

+ (UIColor *)yammerGray {
  return [UIColor colorWithRed:0.27 green:0.34 blue:0.39 alpha:1.0];
}

- (void)setupView:(UIViewController *)view title:(NSString *)title image:(NSString *)image {
  view.title = title;
  view.tabBarItem.image = [UIImage imageNamed:image];
  //  view.tabBarItem.badgeValue = @"9,334";
  
  view.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Back";
  view.navigationItem.backBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
}

- (void)loadView {
  [super loadView];
  
  UINavigationController *localNavigationController;
  NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:5];
  
  FeedMessageList *theView = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getFeedInfo] refresh:YES compose:YES thread:NO] autorelease];
  [self setupView:theView title:@"My Feed" image:@"home.png"];
	localNavigationController = [[[UINavigationController alloc] initWithRootViewController:theView] autorelease];
  [localViewControllersArray addObject:localNavigationController];

  FeedMessageList *received = [[[FeedMessageList alloc] initWithFeed:[LocalStorage getReceivedInfo] refresh:YES compose:YES thread:NO] autorelease];
  [self setupView:received title:@"Received" image:@"received.png"];
	localNavigationController = [[[UINavigationController alloc] initWithRootViewController:received] autorelease];
  [localViewControllersArray addObject:localNavigationController];
  
  FeedList* feedView = [[[FeedList alloc] init] autorelease];
  [self setupView:feedView title:@"Feeds" image:@"feeds.png"];
	localNavigationController = [[[UINavigationController alloc] initWithRootViewController:feedView] autorelease];
  [localViewControllersArray addObject:localNavigationController];
    
  DirectoryList* directory = [[[DirectoryList alloc] init] autorelease];
  [self setupView:directory title:@"Directory" image:@"directory.png"];
	localNavigationController = [[[UINavigationController alloc] initWithRootViewController:directory] autorelease];
  [localViewControllersArray addObject:localNavigationController];
  
  SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
  [self setupView:settingsViewController title:@"Settings" image:@"settings.png"];
	localNavigationController = [[[UINavigationController alloc] initWithRootViewController:settingsViewController] autorelease];
  [localViewControllersArray addObject:localNavigationController];
  
  self.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
}


@end
