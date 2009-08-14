//
//  HomeViewController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataSettings.h"
#import "APIGateway.h"
#import "SettingsAdvancedOptions.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"
#import "SettingsHomeFeed.h"
#import "SettingsPush.h"
#import "NSString+SBJSON.h"

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

  self.theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];  
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  
  self.dataSource = [[DataSettings alloc] init];
	theTableView.dataSource = self.dataSource;

  [NSThread detachNewThreadSelector:@selector(loadUserCurrent) toTarget:self withObject:nil];
	return self;
}

- (void)logout {
  [OAuthGateway logout];
}

- (void)loadView {  
  self.view = theTableView;
}

- (void)loadUserCurrent {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableDictionary *dict;
  NSString *cached = [LocalStorage getFile:USER_CURRENT];
  if (cached)
    dict = (NSMutableDictionary *)[cached JSONValue];
  else
    dict = [APIGateway usersCurrent:@"silent"];
  
  [self.dataSource findEmailFromDict:dict];
    
  [theTableView reloadData];
  [autoreleasepool release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  if (indexPath.section == 0)
    [theTableView deselectRowAtIndexPath:indexPath animated:NO];
  else {
    if (indexPath.row == 1) {
      [theTableView deselectRowAtIndexPath:indexPath animated:YES];
      SettingsPush *localSettingPush = [[SettingsPush alloc] init];
      [self.navigationController pushViewController:localSettingPush animated:YES];
      [localSettingPush release];
    }
    else if (indexPath.row == 2) {
      [theTableView deselectRowAtIndexPath:indexPath animated:YES];
      SettingsAdvancedOptions *localSettingsAdvancedOptions = [[SettingsAdvancedOptions alloc] init];
      [self.navigationController pushViewController:localSettingsAdvancedOptions animated:YES];
      [localSettingsAdvancedOptions release];      
    }
  }  
}

- (void)dealloc {
  [usersCurrent release];
  [dataSource release];
  [theTableView release];
  [super dealloc];
}


@end
