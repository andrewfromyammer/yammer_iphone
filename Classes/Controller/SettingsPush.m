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

@implementation SettingsPush

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;

- (id)init {
  self.title = @"Push Settings";
  return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
	theTableView.delegate = self;  
  NSMutableArray *homeTabs = [APIGateway homeTabs];
  NSMutableArray *filteredHomeTabs = [NSMutableArray array];
  NSMutableDictionary *pushSettings = [APIGateway pushSettings];
    
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 40.0;
}

- (void)dealloc {
  [dataSource release];
  [theTableView release];
  [parent release];
  [super dealloc];
}


@end
