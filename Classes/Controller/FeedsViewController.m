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
#import "LocalStorage.h"
#import "FeedCache.h"
#import "NSString+SBJSON.h"

@implementation FeedsViewController

@synthesize theTableView;
@synthesize dataSource;
@synthesize toolbar;

- (id)init {
  self.toolbar = [[ToolbarWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 35) target:self];
  
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refresh)];  
  self.navigationItem.leftBarButtonItem = refresh;  
  [refresh release];
	return self;
}

- (void)loadView {  
  
  UIView *wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];  
  theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, 320, 332) style:UITableViewStylePlain];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [FeedsTableDataSource getFeeds:nil];
	theTableView.dataSource = self.dataSource;
  [wrapper addSubview:theTableView];
  [wrapper addSubview:self.toolbar];
  
  self.view = wrapper;  
  [wrapper release];
  
  [toolbar displayLoading];
  [toolbar replaceFlexWithSpinner];
  [NSThread detachNewThreadSelector:@selector(loadFeeds) toTarget:self withObject:nil];  
  
}

- (void)loadFeeds {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *dict;
  NSString *cached = [LocalStorage getFile:USER_CURRENT];
  if (cached)
    dict = (NSMutableDictionary *)[cached JSONValue];
  else
    dict = [APIGateway usersCurrent];
  self.dataSource = [FeedsTableDataSource getFeeds:dict];
	theTableView.dataSource = self.dataSource;
  
  [theTableView reloadData];  
  [self.toolbar replaceSpinnerWithFlex];
  [self.toolbar setText:[FeedCache niceDate:[LocalStorage getFileDate:USER_CURRENT]]];
  [autoreleasepool release];
}

- (void)refresh {
  [LocalStorage removeFile:USER_CURRENT];
  [toolbar displayCheckingNew];
  [toolbar replaceFlexWithSpinner];
  [NSThread detachNewThreadSelector:@selector(loadFeeds) toTarget:self withObject:nil];  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] 
                                           initWithDict:[dataSource feedAtIndex:indexPath.row] 
                                           threadIcon:true
                                           refresh:false
                                           compose:true];
  [self.navigationController pushViewController:localFeedMessageList animated:YES];
  [localFeedMessageList release];
}

- (void)dealloc {
  [super dealloc];
  [theTableView release];
  [toolbar release];
  [dataSource release];
}


@end
