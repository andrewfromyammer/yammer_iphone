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

@implementation YammerAppDelegate

@synthesize window;
@synthesize launchURL;
@synthesize mainView;

- (void)askLoginOrSignup {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please login or signup:"
                                                           delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Login", @"Signup", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
  [actionSheet showInView:window];
  [actionSheet release];
}

- (void)setupMainView {
  mainView = [[MainTabBarController alloc] init];
  [window addSubview:mainView.view];
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"deviceToken: %@", deviceToken);
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
  [self performSelector:@selector(postFinishLaunch) withObject:nil afterDelay:0.0];
}

- (void)postFinishLaunch {
  [window setBackgroundColor:[UIColor whiteColor]];
    
  // OAuth stores an access token on local hard drive, if there, user is already authenticated
  if ([LocalStorage getAccessToken]) {
    [self setupMainView];
  } else if ([LocalStorage getRequestToken] && [OAuthGateway getAccessToken:self.launchURL]) {
    [self setupMainView];
  } else {
    [LocalStorage removeRequestToken];
    
    mainView = [UIViewController alloc];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yammer_header.png"]];
    [mainView.view addSubview:imageView];
    [imageView release];
    [window addSubview:mainView.view];
    
    [self askLoginOrSignup];
  }

  [window makeKeyAndVisible];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1)
    [OAuthGateway getRequestToken:true];
  else
    [OAuthGateway getRequestToken:false];
}

+ (void)showError:(NSString *)error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:error delegate:self 
                                        cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
  [alert release];
}

- (void)teleportToUserFeed:(FeedMessageList *)feed {
  MainTabBarController *tabBarController = (MainTabBarController *)mainView;
  UINavigationController *nav = (UINavigationController *)[tabBarController selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  tabBarController.selectedIndex = 1;
  nav = (UINavigationController *)[tabBarController selectedViewController];
  [nav popToRootViewControllerAnimated:NO];
  [nav pushViewController:feed animated:NO];
  [feed release];
}

- (void)dealloc {
  [window release];
  [mainView release];
  [super dealloc];
}


@end
