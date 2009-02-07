//
//  MainTabsController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "MainTabBarController.h"
#import "FeedsViewController.h"
#import "DirectoryViewController.h"
#import "SettingsViewController.h"
#import "FeedMessageList.h";
#import "LocalStorage.h"

@implementation MainTabBarController

+ (UIColor *)yammerGray {
  return [UIColor colorWithRed:0.27 green:0.34 blue:0.39 alpha:1.0];
}

+ (UIColor *)yammerBlue {
  return [UIColor colorWithRed:0.44 green:0.80 blue:0.94 alpha:1.0];
}

+ (void)setBackButton:(UIViewController *)view {
  UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
  temporaryBarButtonItem.title=@"Back";
  view.navigationItem.backBarButtonItem = temporaryBarButtonItem;
  [temporaryBarButtonItem release];
}

- (void)setupView:(UIViewController *)view title:(NSString *)title image:(NSString *)image {
  view.title = title;
  view.tabBarItem.image = [UIImage imageNamed:image];

  view.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]];
  [MainTabBarController setBackButton:view];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  [super loadView];
  
  UINavigationController *localNavigationController;
  NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:4];
  
  // first tab: home
  FeedMessageList *homeViewController = [[FeedMessageList alloc] initWithDict:[LocalStorage getFeedInfo] 
                                                                    textInput:true 
                                                                   threadIcon:true
                                                                      homeTab:true];
  [self setupView:homeViewController title:@"Home" image:@"home.png"];
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
  [homeViewController release];
  [localNavigationController.navigationBar setTintColor:[MainTabBarController yammerGray]];
  [localViewControllersArray addObject:localNavigationController];
  [localNavigationController release];

  // second tab: feeds
  FeedsViewController *feedViewController = [[FeedsViewController alloc] init];
  [self setupView:feedViewController title:@"Feeds" image:@"feeds.png"];
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:feedViewController];
  [feedViewController release];
  [localNavigationController.navigationBar setTintColor:[MainTabBarController yammerGray]];
  [localViewControllersArray addObject:localNavigationController];
  [localNavigationController release];

  // third tab: directory
  DirectoryViewController *directoryViewController = [[DirectoryViewController alloc] init];
  [self setupView:directoryViewController title:@"Directory" image:@"directory.png"];
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:directoryViewController];
  [directoryViewController release];
  [localNavigationController.navigationBar setTintColor:[MainTabBarController yammerGray]];
  [localViewControllersArray addObject:localNavigationController];
  [localNavigationController release];

  // fourth tab: settings
  SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
  [self setupView:settingsViewController title:@"Settings" image:@"settings.png"];
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
  [settingsViewController release];
  [localNavigationController.navigationBar setTintColor:[MainTabBarController yammerGray]];
  [localViewControllersArray addObject:localNavigationController];
  [localNavigationController release];
  
  self.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [super dealloc];
}


@end
