//
//  HomeViewController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer Inc. All rights reserved.
//

#import "FeedsViewController.h"
#import "FeedMessageList.h"
#import "APIGateway.h"

@implementation FeedsViewController

@synthesize theTableView;
@synthesize dataSource;

- (id)init {
  
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refresh)];  
  self.navigationItem.rightBarButtonItem = refresh;  
  self.navigationItem.leftBarButtonItem = nil;
  
	return self;
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                                   style:UITableViewStylePlain];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  NSMutableDictionary *dict = [APIGateway usersCurrent];
  self.dataSource = [FeedsTableDataSource getFeeds:dict];
	theTableView.dataSource = self.dataSource;
  
  self.view = theTableView;
  
  [super getData];
  [autoreleasepool release];
}

- (void)refresh {
  [super refresh];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] 
                                           initWithDict:[dataSource feedAtIndex:indexPath.row] 
                                           textInput:true
                                           threadIcon:true
                                           homeTab:false];
  [self.navigationController pushViewController:localFeedMessageList animated:YES];
  [localFeedMessageList release];
}

- (void)dealloc {
  [super dealloc];
  [theTableView release];
  [dataSource release];
}


@end
