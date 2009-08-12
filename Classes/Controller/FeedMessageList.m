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
#import "ComposeMessageController.h"
#import "FeedCache.h"
#import "NSDate-Ago.h"
#import "Message.h"

@implementation FeedMessageList

@synthesize theTableView;
@synthesize dataSource;
@synthesize feed;
@synthesize tableAndSpinner;
@synthesize threadIcon;
@synthesize homeTab;
@synthesize spinnerWithText;

- (id)initWithDict:(NSMutableDictionary *)dict threadIcon:(BOOL)showThreadIcon
                                                  refresh:(BOOL)showRefresh
                                                  compose:(BOOL)showCompose {
  self.feed = dict;
  self.title = [feed objectForKey:@"name"];
  self.threadIcon = showThreadIcon;
  
  self.spinnerWithText = [[SpinnerWithText alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
  
  if (showRefresh) {
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(refresh)];  
    self.navigationItem.leftBarButtonItem = refresh;
  }
  
  if (showCompose) {
    UIBarButtonItem *compose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                             target:self
                                                                             action:@selector(compose)];  
    self.navigationItem.rightBarButtonItem = compose;
  }
  
  self.tableAndSpinner = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
  self.tableAndSpinner.backgroundColor = [UIColor whiteColor];
  
  int height = 337;
  if (!self.threadIcon)
    height = 385;
  self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, height) style:UITableViewStylePlain];
	self.theTableView.autoresizingMask = (UIViewAutoresizingNone);
	self.theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	self.theTableView.delegate = self;
  self.dataSource = [[FeedDataSource alloc] initWithFeed:[feed objectForKey:@"url"]];
	self.theTableView.dataSource = self.dataSource;
    
  //[spinnerWithText displayLoadingCache];
  //[NSThread detachNewThreadSelector:@selector(loadCachedMessages) toTarget:self withObject:nil];    
  [self.spinnerWithText displayCheckingNew];
  [spinnerWithText showTheSpinner];
  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:@"silent"];  
	return self;
}

- (void)loadView {
  [tableAndSpinner addSubview:self.spinnerWithText];
  [tableAndSpinner addSubview:self.theTableView];

  self.view = tableAndSpinner;
}

- (void)loadCachedMessages {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
  self.dataSource = [FeedDataSource getMessages:feed];
 	self.theTableView.dataSource = self.dataSource;
  
  [self.theTableView reloadData];

  [self.spinnerWithText displayCheckingNew];
  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:@"silent"];  
  [autoreleasepool release];
}

- (void)checkForNewMessages:(NSString *)style {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
  NSNumber *newerThan=nil;
  @try {
    Message *m = [dataSource.fetcher.fetchedObjects objectAtIndex:0];
    newerThan = m.message_id;
  } @catch (NSException *theErr) {}
    
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] newerThan:newerThan style:style];
  if (dict) {
    //BOOL previousValue = dataSource.olderAvailable;
    
    [dataSource proccesMessages:dict checkNew:true];
    //NSMutableArray *messages = [result objectForKey:@"messages"];
    
    //[dataSource processImagesAndTime:messages];
    
   // if (![result objectForKey:@"replace_all"] && newerThan != nil) {
      //[messages addObjectsFromArray:[NSMutableArray arrayWithArray:dataSource.messages]];
      //dataSource.olderAvailable = previousValue;
    //}
    //dataSource.messages = messages;
    
//    self.dataSource.feed = [FeedCache feedCacheUniqueID:[feed objectForKey:@"url"]];
    [dataSource fetch];
    [theTableView reloadData];
  }
  
  [self displayLastUpdated];
  [spinnerWithText hideTheSpinner];
  [autoreleasepool release];
}

- (void)displayLastUpdated {
  NSDate *date = [FeedCache loadFeedDate:[feed objectForKey:@"url"]];  
  if (date)
    [self.spinnerWithText setText:[FeedCache niceDate:date]];
  else
    [self.spinnerWithText setText:@"No updates yet"];
}

- (void)compose {
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];

  NSString *name = [feed objectForKey:@"name"];
  if ([[feed objectForKey:@"type"] isEqualToString:@"group"])
    [meta setObject:[feed objectForKey:@"group_id"] forKey:@"group_id"];
  else
    name = @"My Colleagues";
  [meta setObject:[NSString stringWithFormat:@"Share something with %@:", name] forKey:@"display"];

  
  [self presentModalViewController:[ComposeMessageController getNav:meta] animated:YES];
}

- (void)refresh {
  [spinnerWithText displayCheckingNew];
  [spinnerWithText showTheSpinner];
  
  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1)
    return 50.0;
  // NSString UIKit Additions Reference
  // UILineBreakModeTailTruncation UILineBreakModeWordWrap
  // [NSString sizeWithFont] 
  // CGSize maxSize = CGSizeMake(mViewBounds.size.width, [UIFont labelFontSize]);
  // mTempSize = [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UILineBreakModeTailTruncation];
  // [self prepLayoutForCellAtIndex:index];
  UITableViewCell *cell = [dataSource tableView: tableView cellForRowAtIndexPath: indexPath];
  return cell.bounds.size.height;

  //MessageTableCell *cell = (MessageTableCell *)[dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  //if ([cell length] > 50)
  //  return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    MessageViewController *localMessageViewController = [[MessageViewController alloc] 
                                                         initWithBooleanForThreadIcon:threadIcon 
                                                         list:dataSource.fetcher.fetchedObjects
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

  Message *m = [dataSource.fetcher.fetchedObjects lastObject];
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:m.message_id style:nil];
  if (dict) {
    [dataSource proccesMessages:dict checkNew:false];
    //NSMutableArray *messages = [result objectForKey:@"messages"];
    //[dataSource processImagesAndTime:messages];
    //[dataSource.messages addObjectsFromArray:messages];
  }
  
  NSUInteger newIndex[] = {1, 0};
  NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
  SpinnerCell *cell = (SpinnerCell *)[theTableView cellForRowAtIndexPath:newPath];
  [newPath release];
  
  [cell hideSpinner];
  [cell displayMore];

  [dataSource fetch];
  [theTableView reloadData];
  [autoreleasepool release];
}


- (void)dealloc {
  [theTableView release];
  [dataSource release];
  [feed release];
  [spinnerWithText release];
  [tableAndSpinner release];
  [super dealloc];
}

@end
