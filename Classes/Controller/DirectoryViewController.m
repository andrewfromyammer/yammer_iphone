//
//  HomeViewController.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 Yammer Inc. All rights reserved.
//

#import "DirectoryViewController.h"
#import "DirectoryTableDataSource.h"
#import "DirectoryUserProfile.h";
#import "APIGateway.h"
#import "NSString+SBJSON.h"
#import "LocalStorage.h"
#import "FeedCache.h"
#import "SpinnerCell.h"

@implementation DirectoryViewController

@synthesize theTableView;
@synthesize dataSource;
@synthesize spinnerWithText;
@synthesize wrapper;

- (id)init {
  self.spinnerWithText = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refresh)];  
  self.navigationItem.leftBarButtonItem = refresh;
  
  self.wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];  
  self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 337) style:UITableViewStylePlain];
  
	self.theTableView.autoresizingMask = (UIViewAutoresizingNone);
	self.theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	self.theTableView.delegate = self;
  self.dataSource = [[DirectoryTableDataSource alloc] init];
	self.theTableView.dataSource = self.dataSource;
  
    
  [spinnerWithText displayLoading];
  [spinnerWithText showTheSpinner];
  [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:@"silent"];  
  
  return self;
}

- (void)loadView {
  [wrapper addSubview:self.spinnerWithText];
  [wrapper addSubview:self.theTableView];

  self.view = self.wrapper;
}

- (void)loadUsers:(NSString *)style {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableArray *list;
  NSString *cached = [LocalStorage getFile:DIRECTORY_CACHE];
  if (cached && style != nil)
    list = (NSMutableArray *)[cached JSONValue];
  else {
    list = [APIGateway users:1 style:style];
    if (list == nil && cached)
      list = (NSMutableArray *)[cached JSONValue];
  }
  
  [self.dataSource handleUsers:list];
  [theTableView reloadData];  
  
  [self.spinnerWithText hideTheSpinner];
  [self.spinnerWithText setText:[FeedCache niceDate:[LocalStorage getFileDate:DIRECTORY_CACHE]]];
  [autoreleasepool release];
}

- (void)refresh {
  self.dataSource.users = [NSMutableArray array];
  [spinnerWithText displayCheckingNew];
  [spinnerWithText showTheSpinner];
  [NSThread detachNewThreadSelector:@selector(loadUsers:) toTarget:self withObject:nil];  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  
  [theTableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == 0) {
    NSMutableDictionary *user = [dataSource getUser:indexPath.row];
    DirectoryUserProfile *localDirectoryUserProfile = [[DirectoryUserProfile alloc] 
                                                       initWithUserId:[[user objectForKey:@"id"] description]
                                                       tabs:true];
    [self.navigationController pushViewController:localDirectoryUserProfile animated:YES];
    [localDirectoryUserProfile release];
  } else {
    if ([dataSource.users count] < 500) {
      SpinnerCell *cell = (SpinnerCell *)[tableView cellForRowAtIndexPath:indexPath];
      [cell showSpinner];
      [cell.displayText setText:@"Loading More..."];
      [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:self withObject:nil];
    }
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  dataSource.page++;
  NSMutableArray *array = [APIGateway users:dataSource.page style:nil];
  if (array)
    [dataSource handleUsers:array];
  [theTableView reloadData];
  [autoreleasepool release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.0;
}

- (void)dealloc {
  [theTableView release];
  [dataSource release];
  [spinnerWithText release];
  [wrapper release];
  [super dealloc];
}


@end
