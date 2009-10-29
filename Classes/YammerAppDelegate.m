
#import "YammerAppDelegate.h"
#import "FeedMessageList.h"
#import "MainTabBar.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "OAuthGateway.h"
#import "MessageDetail.h"
#import "UserProfile.h"
#import "NSString+SBJSON.h"
#import "EnterCallbackToken.h"
#import "OAuthCustom.h"

@implementation YammerAppDelegate

@synthesize showFullNames;
@synthesize launchURL;
@synthesize network_id;
@synthesize threading, createNewAccount;
@synthesize unseen_message_count_following, unseen_message_count_received, last_seen_message_id;
@synthesize lastAutocomplete;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSString* token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                     stringByReplacingOccurrencesOfString:@">" withString:@""]
                    stringByReplacingOccurrencesOfString:@" " withString:@""];
  
  [APIGateway sendPushToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error in registration. Error: %@", error); 
}

- (NSString*)version {
  return @"2.0.2.26";
}

- (void)applicationDidFinishLaunching:(UIApplication*)application {
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];  

  self.unseen_message_count_following = -1;
  self.unseen_message_count_received = -1;
  self.last_seen_message_id = -1;
  self.lastAutocomplete = [NSDate date];
  
  UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  window.backgroundColor = [UIColor whiteColor];
  UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
  image.frame = CGRectMake(0, 0, 320, 480);
  [window addSubview:image];
  [image release];
  [window makeKeyAndVisible];
  
  NSString *user_current = [LocalStorage getFile:USER_CURRENT];
  if (user_current) {
    if ([[ NSDate date] timeIntervalSinceDate: [LocalStorage getFileDate:USER_CURRENT] ] > 60 * 60 * 24)
      [APIGateway usersCurrent:@"silent"];
  }
  
  // OAuth stores an access token on local hard drive, if there, user is already authenticated
  if ([LocalStorage getAccessToken] && user_current != nil)
    [self setupNavigator];
  else if ([LocalStorage getAccessToken] && user_current == nil && [APIGateway usersCurrent:@"silent"])
    [self setupNavigator];
  else 
    [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];
}

- (void)showEnterCallbackTokenScreen {
  UIWindow* window = [[UIApplication sharedApplication] keyWindow];
  [[[window subviews] objectAtIndex:0] removeFromSuperview];
  
  EnterCallbackToken* ecbt = [[EnterCallbackToken alloc] init];
  UINavigationController* nav = [[UINavigationController alloc] init];
  [nav setViewControllers:[NSArray arrayWithObject:ecbt]];
  [window addSubview:nav.view];
}

- (void)setupNavigator {  
  UIWindow* window = [[UIApplication sharedApplication] keyWindow];
  [[[window subviews] objectAtIndex:0] removeFromSuperview];
  
  long nid = [[[[LocalStorage getFile:USER_CURRENT] JSONValue] objectForKey:@"network_id"] longValue];
  self.network_id = [[NSNumber alloc] initWithLong:nid];
  self.threading = [LocalStorage threadingFromDisk];

  //[TTURLRequestQueue mainQueue].userAgent = @"Mobile Yammer iPhone/iPod Touch";
  if (true)
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeNone;
  
  TTURLMap* map = navigator.URLMap;
 
  [map from:@"*" toViewController:[TTWebController class]];
  [map from:@"yammer://tabs" toViewController:[MainTabBar class]];
  [map from:@"yammer://user" toViewController:[UserProfile class]];

  [navigator openURL:@"yammer://tabs" animated:NO];
}

- (void)postFinishLaunch {
  if ([LocalStorage getRequestToken] && [OAuthCustom callbackTokenInURL] && 
      [OAuthGateway getAccessToken:self.launchURL callbackToken:nil] && [APIGateway usersCurrent:@"silent"])
    [self setupNavigator];
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
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  self.createNewAccount = YES;
  
  if (buttonIndex == 0)
    self.createNewAccount = NO;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yammer" message:@"This app will temporarily exit and the browser will open so you can authorize it.  The app will re-open when you are done."
                                                 delegate:self cancelButtonTitle:nil otherButtonTitles:@"Open Browser", nil];
  [alert show];
  [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  [OAuthGateway getRequestToken:self.createNewAccount];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  self.launchURL = [url description];
  return true;
}

- (void)setBadge:(FeedMessageList*)fml count:(int)count {
  fml.tabBarItem.badgeValue = nil;
  if (count > 0) {
    if (count > 60)
      fml.tabBarItem.badgeValue = @"60+";
    else
      fml.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", count];   
  }  
}

- (void)setBadges:(NSString*)style {
  TTNavigator* navigator = [TTNavigator navigator];
  MainTabBar* mainView = (MainTabBar*)[navigator rootViewController];
  UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:0];
  FeedMessageList *myfeed = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];
  nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:1];
  FeedMessageList *received = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];

  [self setBadge:myfeed   count:self.unseen_message_count_following];
  [self setBadge:received count:self.unseen_message_count_received];
  
  [received refreshFeed:@"silent"];
}

- (void)refreshMyFeed {
  TTNavigator* navigator = [TTNavigator navigator];
  MainTabBar* mainView = (MainTabBar*)[navigator rootViewController];
  UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:0];
  FeedMessageList *myfeed = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];
  [myfeed refreshFeed:nil];
}

- (void)resetForNewThreadingValue {
  TTNavigator* navigator = [TTNavigator navigator];
  MainTabBar* mainView = (MainTabBar*)[navigator rootViewController];
  
  int i=0;
  for (i=0; i<2; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
    FeedMessageList *fml = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];
    [fml replaceFeed];
  }
  
  for (i=2; i<5; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
  }  
}

- (void)resetForNewNetwork {
  TTNavigator* navigator = [TTNavigator navigator];
  MainTabBar* mainView = (MainTabBar*)[navigator rootViewController];
  
  int i=0;
  for (i=0; i<2; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
    FeedMessageList *fml = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];
    [fml replaceFeed];    
  }
  
  [self refreshMyFeed];
  
  for (i=2; i<5; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
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
  [showFullNames release];
  [launchURL release];
  [lastAutocomplete release];
  [super dealloc];
}


@end
