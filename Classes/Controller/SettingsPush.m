//
//  SettingsPush.m
//  Yammer
//
//  Created by aa on 2/3/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "SettingsPush.h"
#import "FeedsTableDataSource.h"
#import "LocalStorage.h"
#import "APIGateway.h"

@implementation SettingsPush

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;

- (id)init {
  self.title = @"Push Notice Feeds";
  return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
	theTableView.delegate = self;  
  NSMutableArray *pushSettings = [APIGateway pushSettings];
  NSLog([pushSettings description]);
  self.dataSource = [FeedsTableDataSource getFeeds:[APIGateway usersCurrent] klass:@"SettingsPush"];
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
