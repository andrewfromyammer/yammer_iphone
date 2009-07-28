//
//  FeedMessageList.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedMessageList.h"
#import "FeedDataSource.h"
#import "MessageTableCell.h"
#import "MainTabBarController.h"
#import "APIGateway.h"
#import "MessageViewController.h"
#import "LocalStorage.h"
#import "SpinnerCell.h"
#import "ComposeYamController.h"

@implementation FeedMessageList

@synthesize theTableView;
@synthesize dataSource;
@synthesize feed;
@synthesize tableAndSpinner;
@synthesize threadIcon;
@synthesize homeTab;
@synthesize topSpinner;

- (id)initWithDict:(NSMutableDictionary *)dict threadIcon:(BOOL)showThreadIcon homeTab:(BOOL)isHomeTab {
  self.feed = dict;
  self.title = [feed objectForKey:@"name"];
  self.threadIcon = showThreadIcon;
  self.homeTab = isHomeTab;
  [self addComposeButton];
	return self;
}

- (void)showTable {  
  self.topSpinner = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  self.topSpinner.target = self;

  [tableAndSpinner addSubview:topSpinner];
  [tableAndSpinner addSubview:theTableView];
  self.view = tableAndSpinner;
  
}

- (void)getData {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  self.tableAndSpinner = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  tableAndSpinner.backgroundColor = [UIColor whiteColor];
    
  theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 337) style:UITableViewStylePlain];  
	theTableView.autoresizingMask = (UIViewAutoresizingNone);
	theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	theTableView.delegate = self;
  self.dataSource = [FeedDataSource getMessages:feed];  
	theTableView.dataSource = self.dataSource;
  [self showTable];
  [super getData];

  [topSpinner showTheSpinner:[SpinnerWithText checkingNewString]];
  
  [NSThread detachNewThreadSelector:@selector(setStatus) toTarget:self withObject:nil];

  [autoreleasepool release];
}

- (void)setStatus {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  if (self.dataSource.statusMessage == nil) {

    NSMutableDictionary *message = [dataSource.messages objectAtIndex:0];
    NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] newerThan:[message objectForKey:@"id"]];
    if (dict) {
      BOOL previousValue = dataSource.olderAvailable;
      NSMutableArray *messages = [dataSource proccesMessages:dict feed:feed];            
      dataSource.olderAvailable = previousValue;
      
      [dataSource processImages:messages];
      [messages addObjectsFromArray:dataSource.messages];
      dataSource.messages = messages;
      [theTableView reloadData];
    }
  }
  [self.topSpinner hideTheSpinner:@"Updated 12:34 PM"];
  [autoreleasepool release];
}

- (void)compose {
  ComposeYamController *compose = [[ComposeYamController alloc] initWithSpinner:self.topSpinner feed:feed];
  UINavigationController *modal = [[UINavigationController alloc] initWithRootViewController:compose];
  [modal.navigationBar setTintColor:[MainTabBarController yammerGray]];

  [self presentModalViewController:modal animated:YES];  
}

- (void)topSpinnerClicked {
  [topSpinner showTheSpinner:[SpinnerWithText checkingNewString]];
  self.dataSource.statusMessage = nil;
  [NSThread detachNewThreadSelector:@selector(setStatus) toTarget:self withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1)
    return 50.0;

  MessageTableCell *cell = (MessageTableCell *)[dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  if ([cell length] > 50)
    return 65.0;
  return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    MessageViewController *localMessageViewController = [[MessageViewController alloc] 
                                                         initWithBooleanForThreadIcon:threadIcon 
                                                         list:[dataSource messages] 
                                                         index:indexPath.row];
    [self.navigationController pushViewController:localMessageViewController animated:YES];
    [localMessageViewController release];
  } else {
    if ([dataSource.messages count] < 999) {
      SpinnerCell *cell = (SpinnerCell *)[tableView cellForRowAtIndexPath:indexPath];
      [cell showSpinner];
      [cell.displayText setText:@"Loading More..."];
      [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:self withObject:nil];
    }
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *message = [dataSource.messages objectAtIndex:[dataSource.messages count]-1];
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:[message objectForKey:@"id"]];
  if (dict) {
    NSMutableArray *messages = [dataSource proccesMessages:dict feed:feed];
    [dataSource processImages:messages];
    [dataSource.messages addObjectsFromArray:messages];
  }
  
  NSUInteger newIndex[] = {1, 0};
  NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
  SpinnerCell *cell = (SpinnerCell *)[theTableView cellForRowAtIndexPath:newPath];
  [newPath release];
  
  [cell hideSpinner];
  [cell displayMore];

  [theTableView reloadData];
  [autoreleasepool release];
}


- (void)dealloc {
  [theTableView release];
  [dataSource release];
  [feed release];
  [topSpinner release];
  [tableAndSpinner release];
  [super dealloc];
}

@end
