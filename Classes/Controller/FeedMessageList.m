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
@synthesize curOffset;
@synthesize isChecking;

- (id)initWithDict:(NSMutableDictionary *)dict threadIcon:(BOOL)showThreadIcon
                                                  refresh:(BOOL)showRefresh
                                                  compose:(BOOL)showCompose {
  self.feed = dict;
  self.curOffset = 0;
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
  
  int height = 385;
  if (self.threadIcon || ([feed objectForKey:@"isThread"] != nil && [LocalStorage threading]))
    height = 337;
  
  self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, height) style:UITableViewStylePlain];
	self.theTableView.autoresizingMask = (UIViewAutoresizingNone);
	self.theTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	self.theTableView.delegate = self;
  self.dataSource = [[FeedDataSource alloc] initWithFeed:feed];
	self.theTableView.dataSource = self.dataSource;
  
  [self.spinnerWithText displayLoadingCache];    
  [NSThread detachNewThreadSelector:@selector(loadFromCache) toTarget:self withObject:nil];  
	return self;
}

- (void)loadView {
  [tableAndSpinner addSubview:self.spinnerWithText];
  [tableAndSpinner addSubview:self.theTableView];

  self.view = tableAndSpinner;
}

- (void)loadFromCache {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  self.curOffset = 0;
  [dataSource fetch:nil];    
  [theTableView reloadData];
  [self.spinnerWithText displayCheckingNew];
  [spinnerWithText showTheSpinner];
  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:@"silent"];  
  [autoreleasepool release];
}

- (void)checkForNewMessages:(NSString *)style {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  
  self.isChecking = true;
  NSNumber *newerThan=nil;
  @try {
    Message *m = [dataSource.messages objectAtIndex:0];
    if ([LocalStorage threading] && [feed objectForKey:@"isThread"] == nil) 
      newerThan = m.latest_reply_id;
    else
      newerThan = m.message_id;
  } @catch (NSException *theErr) {}
    
  NSMutableDictionary *dict = [APIGateway messages:feed newerThan:newerThan style:style];
  if (dict) {
    [dataSource proccesMessages:dict checkNew:true newerThan:newerThan];
    [dataSource.messages removeAllObjects];
    self.curOffset = 0;
    [dataSource fetch:nil];
    [theTableView reloadData];
  }
  
  if ([dataSource.messages count] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note"
                                                    message:@"No messages in this feed yet." delegate:self 
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
  }
  
  [self displayLastUpdated];
  [spinnerWithText hideTheSpinner];
  self.isChecking = false;
  [autoreleasepool release];
}

- (void)displayLastUpdated {
  NSDate *date = [FeedCache loadFeedDate:feed];
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
  [meta setObject:[NSString stringWithFormat:@"To: %@", name] forKey:@"display"];

  
  [self presentModalViewController:[ComposeMessageController getNav:meta] animated:YES];
}

- (void)refresh {
  // deal with with threading mode is back
  //self.dataSource = [[FeedDataSource alloc] initWithFeed:feed];
	//self.theTableView.dataSource = self.dataSource;
  
  [spinnerWithText displayCheckingNew];
  [spinnerWithText showTheSpinner];
  
  [NSThread detachNewThreadSelector:@selector(checkForNewMessages:) toTarget:self withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1)
    return 50.0;
  UITableViewCell *cell = [dataSource tableView: tableView cellForRowAtIndexPath: indexPath];
  return cell.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    Message *message = [dataSource.messages objectAtIndex:indexPath.row];

    if ([LocalStorage threading] && [feed objectForKey:@"isThread"] == nil) {
      if ([message.thread_updates intValue] > 1) {
        NSMutableDictionary *threadFeed = [NSMutableDictionary dictionary];
        [threadFeed setObject:message.thread_url forKey:@"url"];
        [threadFeed setObject:@"true" forKey:@"isThread"];
        
        FeedMessageList *localFeedMessageList = [[FeedMessageList alloc] initWithDict:threadFeed threadIcon:false refresh:false compose:false];
        localFeedMessageList.title = @"Thread";
        [self.navigationController pushViewController:localFeedMessageList animated:YES];
        [localFeedMessageList release];
      } else {
        MessageViewController *localMessageViewController = [[MessageViewController alloc] 
                                                             initWithBooleanForThreadIcon:threadIcon 
                                                             list:[NSArray arrayWithObjects: message, nil]
                                                             index:0];
        [self.navigationController pushViewController:localMessageViewController animated:YES];
        [localMessageViewController release];        
      }
    } else {
      
      if (indexPath.row > 20 && isChecking)
        return;
      
      MessageViewController *localMessageViewController = [[MessageViewController alloc] 
                                                           initWithBooleanForThreadIcon:threadIcon 
                                                           list:dataSource.messages
                                                           index:indexPath.row];
      [self.navigationController pushViewController:localMessageViewController animated:YES];
      [localMessageViewController release];    
    }
  } else {
    SpinnerCell *cell = (SpinnerCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell showSpinner];
    [cell.displayText setText:@"Loading More..."];
    [NSThread detachNewThreadSelector:@selector(fetchMore) toTarget:self withObject:nil];
  }
}

- (void)fetchMore {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  int before = [dataSource.messages count];
  curOffset += 20;  
  [dataSource fetch:[NSNumber numberWithInt:curOffset]];
  
  if (before == [dataSource.messages count]) {
    Message *m = [dataSource.messages lastObject];
    NSMutableDictionary *dict = [APIGateway messages:feed olderThan:m.message_id style:nil];
    if (dict)
      [dataSource proccesMessages:dict checkNew:false newerThan:nil];
    [dataSource fetch:[NSNumber numberWithInt:curOffset]];
  } else
    curOffset -= 20 - ([dataSource.messages count] - before);
  
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
  [spinnerWithText release];
  [tableAndSpinner release];
  [super dealloc];
}

@end
