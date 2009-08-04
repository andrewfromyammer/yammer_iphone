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
@synthesize toolbar;

- (id)init {
  self.toolbar = [[ToolbarWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 35) target:self];
  
  UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                           target:self
                                                                           action:@selector(refresh)];  
  self.navigationItem.leftBarButtonItem = refresh;
  
  return self;
}

- (void)loadView {
    
  UIView *wrapper = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];  
  theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, 320, 332) style:UITableViewStylePlain];
    
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [[DirectoryTableDataSource alloc] init];
	theTableView.dataSource = self.dataSource;

  [wrapper addSubview:toolbar];
  [wrapper addSubview:theTableView];
  
  self.view = wrapper;  
  
  [toolbar displayLoading];
  [toolbar replaceFlexWithSpinner];
  [NSThread detachNewThreadSelector:@selector(loadUsers) toTarget:self withObject:nil];  
}

- (void)loadUsers {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  NSMutableArray *list;
  NSString *cached = [LocalStorage getFile:DIRECTORY_CACHE];
  if (cached)
    list = (NSMutableArray *)[cached JSONValue];
  else
    list = [APIGateway users:1];
  
  [self.dataSource handleUsers:list];
  [theTableView reloadData];  
  
  [self.toolbar replaceSpinnerWithFlex];
  [self.toolbar setText:[FeedCache niceDate:[LocalStorage getFileDate:DIRECTORY_CACHE]]];
  [autoreleasepool release];
}

- (void)refresh {
  self.dataSource.users = [NSMutableArray array];
  [LocalStorage removeFile:DIRECTORY_CACHE];
  [toolbar displayCheckingNew];
  [toolbar replaceFlexWithSpinner];
  [NSThread detachNewThreadSelector:@selector(loadUsers) toTarget:self withObject:nil];  
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
  NSMutableArray *array = [APIGateway users:dataSource.page];
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
  [toolbar release];
  [super dealloc];
}


@end
