
#import "YammerAppDelegate.h"
#import "FeedMessageList.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "OAuthGateway.h"
#import "MessageDetail.h"
#import "UserProfile.h"
#import "NSString+SBJSON.h"
#import "OAuthCustom.h"
#import "DirectoryList.h"
#import "FeedList.h"
#import "SettingsTimeChooser.h"
#import "NetworkList.h"
#import "SettingsPush.h"
#import "LoginPanel.h"

@implementation YammerAppDelegate

@synthesize showFullNames;
@synthesize launchURL;
@synthesize network_id, network_name, pushToken, fontSize;
@synthesize threading, createNewAccount;
@synthesize unseen_message_count_following, unseen_message_count_received, last_seen_message_id;
@synthesize lastAutocomplete;
@synthesize dateOfSelection;
@synthesize lastStatusCode;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  self.pushToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                     stringByReplacingOccurrencesOfString:@">" withString:@""]
                    stringByReplacingOccurrencesOfString:@" " withString:@""];
  [NSThread detachNewThreadSelector:@selector(pushTokenThread) toTarget:self withObject:nil];  
}

- (void)pushTokenThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [APIGateway sendPushToken:self.pushToken];
  [autoreleasepool release];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error in registration. Error: %@", error); 
}

- (NSString*)version {
  return @"2.1.3.3";
}

- (void)applicationWillTerminate:(UIApplication *)application {
  TTNavigator* navigator = [TTNavigator navigator];
  UINavigationController* controller = [[navigator visibleViewController] navigationController];
  int count = [[controller viewControllers] count];
  if (count == 1)
    [LocalStorage saveSetting:@"last_in" value:@"list"];
  else
    [LocalStorage saveSetting:@"last_in" value:@"network"];
}

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  self.unseen_message_count_following = -1;
  self.unseen_message_count_received = -1;
  self.last_seen_message_id = -1;
  self.lastAutocomplete = [NSDate date];
  self.fontSize = [LocalStorage fontSizeFromDisk];
  
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = NO;
  navigator.persistenceMode = TTNavigatorPersistenceModeNone;
  
  TTURLMap* map = navigator.URLMap;
	
  [map from:@"*" toViewController:[TTWebController class]];
  [map from:@"yammer://login" toViewController:[LoginPanel class]];
  [map from:@"yammer://user" toViewController:[UserProfile class]];
  [map from:@"yammer://time" toViewController:[SettingsTimeChooser class]];
  [map from:@"yammer://push" toViewController:[SettingsPush class]];
  [map from:@"yammer://networks" toViewController:[NetworkList class]];
  [map from:@"yammer://tabs" toViewController:[MainTabBar class]];
	
  [[[navigator visibleViewController] navigationController] setDelegate:self];
	
  if ([LocalStorage getAccessToken]) {
		UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		window.backgroundColor = [UIColor whiteColor];
		UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		image.frame = CGRectMake(0, 0, 320, 480);
		[window addSubview:image];
		[image release];
		[window makeKeyAndVisible];
		
    [NSThread detachNewThreadSelector:@selector(getNetworksThread) toTarget:self withObject:nil];  
  }
  else {
		[navigator openURL:@"yammer://login" animated:NO];
    //[NSThread detachNewThreadSelector:@selector(postFinishLaunch) toTarget:self withObject:nil];
	}
}

- (void)getNetworksThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [APIGateway networksCurrent:@"silent"];
  UIWindow* window = [[UIApplication sharedApplication] keyWindow];
  [[[window subviews] objectAtIndex:0] removeFromSuperview];	
  [self performSelectorOnMainThread:@selector(enterAppWithAccess) withObject:nil waitUntilDone:NO];  
  [autoreleasepool release];
}

- (void)startTypeAheadThread {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  while (true) {
    sleep(1);
    TTNavigator* navigator = [TTNavigator navigator];
    UINavigationController* controller = [[navigator visibleViewController] navigationController];
    
    if ([[controller viewControllers] count] == 2 ) {
      MainTabBar* mainView = (MainTabBar*)[[controller viewControllers] objectAtIndex:1];
      if ([mainView selectedIndex] == 3) {
        DirectoryList* list = (DirectoryList*)[navigator visibleViewController];
        [list typeAheadThreadUpdate];
      }
    }
    
  }
  [autoreleasepool release];
}

- (void)enterAppWithAccess {  
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

  //UIWindow* window = [[UIApplication sharedApplication] keyWindow];
  //[[[window subviews] objectAtIndex:0] removeFromSuperview];

  self.network_id = (NSNumber*)[LocalStorage getSetting:@"current_network_id"];
  self.network_name = @"Yammer";
  
  NSMutableArray* networks = [[LocalStorage getFile:NETWORKS_CURRENT] JSONValue];  
  NSMutableDictionary* network_dict;
  
  for (NSMutableDictionary *network in networks) {
    if ([[network objectForKey:@"id"] longValue] == [self.network_id longValue]) {      
      self.network_name = [network objectForKey:@"name"];
      network_dict = network;
      break;
    }
  }
    
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURL:@"yammer://networks" animated:NO];

  NSString* last_in = (NSString*)[LocalStorage getSetting:@"last_in"];
  if (last_in == nil || [networks count] == 1)
    last_in = @"network";
  if ([last_in isEqualToString:@"network"]) {
    
    UINavigationController* controller = [[navigator visibleViewController] navigationController];
    NetworkList* networkList = (NetworkList*)[[controller viewControllers] objectAtIndex:0];
    [networkList clearBadgeForNetwork:self.network_id];
    [NetworkList subtractFromBadgeCount:network_dict];

    self.dateOfSelection = [[NSDate date] description];
    [navigator openURL:@"yammer://tabs" animated:NO];
  }
  
  [NSThread detachNewThreadSelector:@selector(startTypeAheadThread) toTarget:self withObject:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/*
- (void)postFinishLaunch {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  usleep(500000);
  
  if ([LocalStorage getRequestToken] && [OAuthCustom callbackTokenInURL] && 
      [OAuthGateway getAccessToken:self.launchURL callbackToken:nil] && [APIGateway usersCurrent:@"silent"] && [APIGateway networksCurrent:@"silent"])    
    [self performSelectorOnMainThread:@selector(setupNavigator) withObject:nil waitUntilDone:NO];  
  else if ([LocalStorage getRequestToken] && ![OAuthCustom callbackTokenInURL])
    [self showEnterCallbackTokenScreen];
  else {
    [LocalStorage removeRequestToken];
    [LocalStorage removeAccessToken];
    
 
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please log in or sign up:"
                                                        delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Log In", @"Sign Up", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:[[TTNavigator navigator] window]];
    [actionSheet release];
		
		
  }
  [autoreleasepool release];
}
*/

- (void)setBadge:(FeedMessageList*)fml count:(int)count {
  fml.tabBarItem.badgeValue = [NetworkList badgeFromIntToString:count];
}

- (void)setBadges:(NSString*)style {
  TTNavigator* navigator = [TTNavigator navigator];
  UINavigationController* controller = [[navigator visibleViewController] navigationController];
  MainTabBar* mainView = (MainTabBar*)[[controller viewControllers] objectAtIndex:1];

  FeedMessageList *myfeed = (FeedMessageList *)[mainView.viewControllers objectAtIndex:0];
  FeedMessageList *received = (FeedMessageList *)[mainView.viewControllers objectAtIndex:1];

  [self setBadge:myfeed   count:self.unseen_message_count_following];
  [self setBadge:received count:self.unseen_message_count_received];
  
  [received refreshFeed:@"silent"];
}

- (void)refreshMyFeed {
  TTNavigator* navigator = [TTNavigator navigator];
  UINavigationController* controller = [[navigator visibleViewController] navigationController];
  MainTabBar* mainView = (MainTabBar*)[[controller viewControllers] objectAtIndex:1];

  FeedMessageList *myfeed = (FeedMessageList *)[mainView.viewControllers objectAtIndex:0];
  [myfeed refreshFeed:nil];
}

- (int)countViewControllers {
  TTNavigator* navigator = [TTNavigator navigator];
  UINavigationController* controller = [[navigator visibleViewController] navigationController];
  
  return [[controller viewControllers] count];
}

- (void)reloadForFontSizeChange {
  TTNavigator* navigator = [TTNavigator navigator];
  UINavigationController* controller = [[navigator visibleViewController] navigationController];
  MainTabBar* mainView = (MainTabBar*)[[controller viewControllers] objectAtIndex:1];
    
  int i=0;
  for (i=0; i<2; i++) {
    FeedMessageList *fml = (FeedMessageList *)[mainView.viewControllers objectAtIndex:i];
    [fml showModel:YES];
  }
}

- (NSManagedObjectContext *) managedObjectContext {
	
  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
  }
  return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	
  if (managedObjectModel != nil) {
    return managedObjectModel;
  }
  managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
	
  NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: MESSAGE_CACHE]];
	
	NSError *error;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
  }    	
  return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
	
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

+ (void)showError:(NSString *)error style:(NSString *)style {
  if (style != nil)
    return;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:error delegate:self 
                                        cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
  [alert release];
}

- (void)dealloc {
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];

  [network_id release];
  [network_name release];
  [showFullNames release];
  [launchURL release];
  [lastAutocomplete release];
  [dateOfSelection release];
  [super dealloc];
}


@end
