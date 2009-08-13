//
//  YammerAppDelegate.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "YammerAppDelegate.h"
#import "LocalStorage.h"
#import "MainTabBarController.h"
#import "OAuthGateway.h"
#import "ApiGateway.h"
#import "NSString+SBJSON.h"

@implementation YammerAppDelegate

@synthesize window;
@synthesize launchURL;
@synthesize mainView;
@synthesize network_id;
@synthesize threading;

- (void)askLoginOrSignup {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please login or signup:"
                                                           delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Login", @"Signup", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  [actionSheet showInView:window];
  [actionSheet release];
}

- (void)setupMainView {
  long nid = [[[[LocalStorage getFile:USER_CURRENT] JSONValue] objectForKey:@"network_id"] longValue];
  self.network_id = [[NSNumber alloc] initWithLong:nid];
  self.threading = [LocalStorage threadingFromDisk];
  
  self.mainView = [[MainTabBarController alloc] init];
  
  UIView *image = [[self.window subviews] objectAtIndex:0];
  [image removeFromSuperview];
  
//  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  [self.window addSubview:mainView.view];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [APIGateway sendPushToken:[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                                                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                                                        stringByReplacingOccurrencesOfString:@" " withString:@""]
                             ];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"Error in registration. Error: %@", error); 
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
   self.launchURL = [url description];
   return true;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {     
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
  image.frame = CGRectMake(0, 0, 320, 480);
  [self.window addSubview:image];
  [self.window makeKeyAndVisible];
  
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];  
  [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];
}

- (void)postFinishLaunch {
  NSString *user_current = [LocalStorage getFile:USER_CURRENT];
  if (user_current) {
    if ([[ NSDate date] timeIntervalSinceDate: [LocalStorage getFileDate:USER_CURRENT] ] > 60 * 60 * 24)
      [APIGateway usersCurrent:@"silent"];
  }
  
  // OAuth stores an access token on local hard drive, if there, user is already authenticated
  if ([LocalStorage getAccessToken] && user_current != nil)
    [self setupMainView];
  else if ([LocalStorage getAccessToken] && user_current == nil && [APIGateway usersCurrent:@"silent"])
    [self setupMainView];
  else if ([LocalStorage getRequestToken] && [OAuthGateway getAccessToken:self.launchURL] && [APIGateway usersCurrent:@"silent"])
    [self setupMainView];
  else {
    [LocalStorage removeRequestToken];
    [LocalStorage removeAccessToken];
    
    mainView = [UIViewController alloc];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yammer_header.png"]];
    [mainView.view addSubview:imageView];
    [imageView release];
    
    UIView *image = [[self.window subviews] objectAtIndex:0];
    [image removeFromSuperview];
    [window addSubview:mainView.view];
    
    [self askLoginOrSignup];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1)
    [OAuthGateway getRequestToken:true];
  else
    [OAuthGateway getRequestToken:false];
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

- (void)teleportToUserFeed:(FeedMessageList *)feed {
  UINavigationController *nav = (UINavigationController *)[mainView selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  mainView.selectedIndex = 2;
  nav = (UINavigationController *)[mainView selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  [nav pushViewController:feed animated:NO];
  [feed release];
}

- (NSManagedObjectContext *)managedObjectContext {
	
	NSManagedObjectContext *context;
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: coordinator];
  }
  return context;
}

- (NSManagedObjectModel *)managedObjectModel {	
  return [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
//  return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {		
	NSString *storePath = [[LocalStorage localPath] stringByAppendingPathComponent: MESSAGE_CACHE];  
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
  
	NSError *error;
	if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
  }
  return coordinator;
}

- (void)resetForNewThreadingValue {
  int i=0;
  for (i=0; i<2; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
    FeedMessageList *fml = (FeedMessageList *)[nav.viewControllers objectAtIndex:0];
    [fml refresh];
  }
  
  for (i=2; i<5; i++) {
    UINavigationController *nav = (UINavigationController *)[mainView.viewControllers objectAtIndex:i];
    [nav popToRootViewControllerAnimated:NO];
  }
}


- (void)dealloc {
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];
  
  [network_id release];
  [window release];
  [mainView release];
  [super dealloc];
}


@end
