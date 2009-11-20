//
//  SettingsPush.m
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "SettingsPush.h"
#import "LocalStorage.h"
#import "APIGateway.h"
#import "MainTabBar.h"
#import "SettingsTimeChooser.h"
#import "YammerAppDelegate.h"
#import "NSString+SBJSON.h"

@implementation SettingsPush

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;
@synthesize timeChooser;
@synthesize picker;

- (id)init {
  if (self = [super init]) {
    self.navigationBarTintColor = [MainTabBar yammerGray];
    self.title = @"Push Settings";
    
    UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title=@"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
  }
  return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
	theTableView.delegate = self;  
  NSMutableArray *homeTabs = [APIGateway homeTabs];
  NSMutableArray *filteredHomeTabs = [NSMutableArray array];
  
  
  NSString* json = [LocalStorage getFile:[NSString stringWithFormat:@"account/push_%@.json", yammer.network_id]];
    
  NSMutableDictionary *pushSettings = nil;
  
  if (json)
    pushSettings = [json JSONValue];
  else
    pushSettings = [APIGateway pushSettings:nil];
      
  NSMutableArray *notifications = [pushSettings objectForKey:@"notifications"];
  NSMutableDictionary *notificationDict = [NSMutableDictionary dictionary];
  int i=0;
  for (i=0; i<[notifications count]; i++) {
    NSMutableDictionary *tab = [notifications objectAtIndex:i];
    [notificationDict setObject:tab forKey:[tab objectForKey:@"name"]];
  }
  for (i=0; i<[homeTabs count]; i++) {
    NSMutableDictionary *tab = (NSMutableDictionary *)[homeTabs objectAtIndex:i];
    if ([notificationDict objectForKey:[tab objectForKey:@"name"]])
      [filteredHomeTabs addObject:tab];
  }
  
  self.dataSource = [[DataSettingsPush alloc] initWithArray:filteredHomeTabs notificationDict:notificationDict pushSettings:pushSettings];
	theTableView.dataSource = self.dataSource;  
  self.view = theTableView;
  
  [super getData];
  [autoreleasepool release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (indexPath.section == 1 && indexPath.row > 0) {
    TTNavigator* navigator = [TTNavigator navigator];
    if (indexPath.row == 1)
      [navigator openURL:[NSString stringWithFormat:@"yammer://time?hour=%@&key=sleep_hour_start", [[dataSource.pushSettings objectForKey:@"sleep_hour_start"] description]] animated:YES];
    else if (indexPath.row == 2)
      [navigator openURL:[NSString stringWithFormat:@"yammer://time?hour=%@&key=sleep_hour_end", [[dataSource.pushSettings objectForKey:@"sleep_hour_end"] description]] animated:YES];
  }
}

- (void)updateTime:(NSInteger)hour ampm:(NSInteger)ampm key:(NSString*)key {
  
  if (ampm == 0 && hour == 11)
    [dataSource.pushSettings setObject:[NSNumber numberWithInt:0] forKey:key];
  else if (ampm == 0)
    [dataSource.pushSettings setObject:[NSNumber numberWithInt:hour+1] forKey:key];
  else if (ampm == 1)
    [dataSource.pushSettings setObject:[NSNumber numberWithInt:hour+13] forKey:key];
  [theTableView reloadData];
  
  NSMutableArray *array = [NSMutableArray array];
  [array addObject:key];
  [array addObject:[[dataSource.pushSettings objectForKey:key] description]];
  [NSThread detachNewThreadSelector:@selector(updateTimeThread:) toTarget:self withObject:array]; 
}

- (void)updateTimeThread:(NSMutableArray *)array {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  [APIGateway updatePushField:[array objectAtIndex:0] value:[array objectAtIndex:1]
                        theId:[dataSource.pushSettings objectForKey:@"id"] 
                        pushSettings:dataSource.pushSettings];
  [autoreleasepool release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 40.0;
}

- (void)dealloc {
  [dataSource release];
  [theTableView release];
  [parent release];
  [timeChooser release];
  [picker release];
  [super dealloc];
}


@end
