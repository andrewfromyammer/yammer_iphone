//
//  HomeViewController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableDataSource.h"
#import "APIGateway.h"
#import "SettingsAdvancedOptions.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"
#import "SettingsChooseFeed.h"
#import "SettingsPush.h"

@implementation SettingsViewController

@synthesize theTableView;
@synthesize usersCurrent;
@synthesize dataSource;

- (id)init {
  
  UIBarButtonItem *logout=[[UIBarButtonItem alloc] init];
  logout.title=@"Logout";
  logout.target = self;
  logout.action = @selector(logout);
  self.navigationItem.rightBarButtonItem = logout;
  [logout release];
  self.navigationItem.leftBarButtonItem = nil;
  
	return self;
}

- (void)logout {
  [OAuthGateway logout];
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];  
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  
  self.usersCurrent = [APIGateway usersCurrent];
  self.dataSource = [[SettingsTableDataSource alloc] initWithDict:self.usersCurrent];
	theTableView.dataSource = self.dataSource;
  
  self.view = theTableView;
  
  [super getData];
  [autoreleasepool release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0)
    return 30.0;
  return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  if (indexPath.row == 0 || indexPath.section == 0)
    [theTableView deselectRowAtIndexPath:indexPath animated:NO];
  else if (indexPath.section == 1) {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingsChooseFeed *localSettingsChooseFeed = [[SettingsChooseFeed alloc] initWithDict:self.usersCurrent parent:self];
    [self.navigationController pushViewController:localSettingsChooseFeed animated:YES];
    [localSettingsChooseFeed release];   
  }  
  else if (indexPath.section == 2) {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingsPush *localSettingPush = [[SettingsPush alloc] initWithDict:self.usersCurrent parent:self];
    [self.navigationController pushViewController:localSettingPush animated:YES];
    [localSettingPush release];
  }  
  else if (indexPath.section == 3) {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingsAdvancedOptions *localSettingsAdvancedOptions = [[SettingsAdvancedOptions alloc] init];
    [self.navigationController pushViewController:localSettingsAdvancedOptions animated:YES];
    [localSettingsAdvancedOptions release];
  }  
  
}

- (void)dealloc {
  [usersCurrent release];
  [dataSource release];
  [theTableView release];
  [super dealloc];
}


@end
