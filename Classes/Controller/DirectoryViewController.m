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

@implementation DirectoryViewController

@synthesize theTableView;
@synthesize dataSource;

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
	theTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]
                                              style:UITableViewStylePlain];
  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [DirectoryTableDataSource getUsers];
	theTableView.dataSource = self.dataSource;
  
  self.view = theTableView;
  
  [super getData];
  [autoreleasepool release];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
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
    if ([dataSource.users count] < 999) {
      self.view = wrapper;
      [spinner startAnimating];  
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
  [super getData];
  self.view = theTableView;
  [autoreleasepool release];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.0;
}

- (void)dealloc {
  [theTableView release];
  [dataSource release];
  [super dealloc];
}


@end
