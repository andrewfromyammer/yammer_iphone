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

@implementation YammerAppDelegate

@synthesize window;
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
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  [window setBackgroundColor:[UIColor whiteColor]];
    
  // OAuth stores an access token on local hard drive, if there, user is already authenticated
  if ([LocalStorage getAccessToken]) {
    [self setupMainView];
  } else if ([LocalStorage getRequestToken] && [OAuthGateway getAccessToken]) {
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
