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

@implementation SettingsPush

@synthesize dataSource;
@synthesize theTableView;
@synthesize parent;

- (id)initWithDict:(NSMutableDictionary *)dict parent:(SettingsViewController *)view {
  self.title = @"Push Notice Feeds";
  self.parent = view;
	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStyleGrouped];  
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;  
  self.dataSource = [FeedsTableDataSource getFeeds:dict klass:@"SettingsPush"];
	theTableView.dataSource = self.dataSource;
  self.view = theTableView;
  
//[toggle addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
  
  return self;
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
