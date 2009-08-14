//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedDataSource.h"
#import "APIGateway.h"
#import "ImageCache.h"
#import "MessageCell.h"
#import "FeedCache.h"
#import "SpinnerCell.h"
#import "Message.h"
#import "YammerAppDelegate.h"
#import "LocalStorage.h"

@implementation FeedDataSource

@synthesize messages;
@synthesize olderAvailable;
@synthesize fetchingMore;
@synthesize feed;
@synthesize fetcher;
@synthesize showReplyCounts;
@synthesize context;

- (id)initWithEmpty {
  self.messages = [NSMutableArray array];
  self.olderAvailable = false;
  return self;
}

- (id)initWithFeed:(NSMutableDictionary *)theFeed {
  self.feed = [FeedCache feedCacheUniqueID:theFeed];
  self.showReplyCounts = false;
  if ([LocalStorage threading] && [theFeed objectForKey:@"isThread"] == nil)
    self.showReplyCounts = true;
  [self fetch];
  return self;
}

- (void)fetch {
  NSString *order_by = @"message_id";
  if (showReplyCounts)
    order_by = @"latest_reply_id";
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:[yam managedObjectContext]];
	[fetchRequest setEntity:entity];
//  [fetchRequest setFetchOffset:0];
//  [fetchRequest setFetchLimit:100];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@", feed];
  [fetchRequest setPredicate:feedPredicate];
  
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:order_by ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	self.fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                     managedObjectContext:[yam managedObjectContext] 
                                                                     sectionNameKeyPath:order_by 
                                                                     cacheName:@"Root"];
  
  NSError *error;
	[fetcher performFetch:&error];
	
	[fetchRequest release];
	[descriptor release];
	[sortDescriptors release];  
}


- (void)proccesMessages:(NSMutableDictionary *)dict checkNew:(BOOL)checkNew {
  NSMutableDictionary *meta = [dict objectForKey:@"meta"];
  NSNumber *older = [meta objectForKey:@"older_available"];
  self.olderAvailable = false;
  if (older && [older intValue] == 1)
    self.olderAvailable = true;
  
  NSMutableArray *references = [dict objectForKey:@"references"];
  
  NSMutableDictionary *referencesByType = [NSMutableDictionary dictionary];
  
  int i=0;
  for (i=0; i < [references count]; i++) {
    NSMutableDictionary *reference = [references objectAtIndex:i];
    NSString *type = [reference objectForKey:@"type"];
    NSString *ref_id = [reference objectForKey:@"id"];
    
    if (type) {
      NSMutableDictionary *referencesById = [referencesByType objectForKey:type];
      if (!referencesById) {
        referencesById = [NSMutableDictionary dictionary];
        [referencesByType setObject:referencesById forKey:type];
      }
      [referencesById setObject:reference forKey:ref_id];
    }
  }
   
  NSMutableArray *tempMessages = [dict objectForKey:@"messages"];

  for (i=0; i < [tempMessages count]; i++) {
    @try {
      NSMutableDictionary *message = [tempMessages objectAtIndex:i];
      NSMutableDictionary *referencesById = [referencesByType objectForKey:[message objectForKey:@"sender_type"]];
      NSMutableDictionary *actor = [referencesById objectForKey:[message objectForKey:@"sender_id"]];
      
      [message setObject:[actor objectForKey:@"mugshot_url"] forKey:@"actor_mugshot_url"];
      [message setObject:[actor objectForKey:@"id"] forKey:@"actor_id"];
      [message setObject:[actor objectForKey:@"type"] forKey:@"actor_type"];
      
      [message setObject:[actor objectForKey:@"name"] forKey:@"sender"];
      referencesById = [referencesByType objectForKey:@"message"];
      NSMutableDictionary *messageRef = [referencesById objectForKey:[message objectForKey:@"replied_to_id"]];
      
      if (messageRef) {
        referencesById = [referencesByType objectForKey:[messageRef objectForKey:@"sender_type"]];
        NSMutableDictionary *actor = [referencesById objectForKey:[messageRef objectForKey:@"sender_id"]];
        [message setObject:[actor objectForKey:@"name"] forKey:@"reply_name"];
      }
      
      referencesById = [referencesByType objectForKey:@"thread"];
      NSMutableDictionary *threadRef = [referencesById objectForKey:[message objectForKey:@"thread_id"]];
      if (threadRef) {  
        [message setObject:[threadRef objectForKey:@"url"] forKey:@"thread_url"];
        NSMutableDictionary *threadStats = [threadRef objectForKey:@"stats"];
        [message setObject:[threadStats objectForKey:@"updates"] forKey:@"thread_updates"];
        [message setObject:[threadStats objectForKey:@"first_reply_id"] forKey:@"thread_first_reply_id"];
        [message setObject:[threadStats objectForKey:@"first_reply_at"] forKey:@"thread_first_reply_at"];
        [message setObject:[threadStats objectForKey:@"latest_reply_id"] forKey:@"thread_latest_reply_id"];
        [message setObject:[threadStats objectForKey:@"latest_reply_at"] forKey:@"thread_latest_reply_at"];
      }
      
      referencesById = [referencesByType objectForKey:@"group"];
      NSMutableDictionary *groupRef = [referencesById objectForKey:[message objectForKey:@"group_id"]];
      
      if (groupRef) {
        [message setObject:[groupRef objectForKey:@"name"] forKey:@"group_name"];
        [message setObject:[groupRef objectForKey:@"full_name"] forKey:@"group_full_name"];
        [message setObject:[groupRef objectForKey:@"privacy"] forKey:@"group_privacy"];
        if ([[groupRef objectForKey:@"privacy"] isEqualToString:@"private"]) {
          [message setObject:[NSString stringWithFormat:@"%@", [groupRef objectForKey:@"name"]] forKey:@"group_name"];
          [message setObject:@"true" forKey:@"lock"];
        }
      }
      
      referencesById = [referencesByType objectForKey:@"user"];
      NSMutableDictionary *directRef = [referencesById objectForKey:[message objectForKey:@"direct_to_id"]];
      
      NSString *fromLine  = [message objectForKey:@"sender"];
      NSString *replyName = [message objectForKey:@"reply_name"];
      
      if (directRef) {
        fromLine = [NSString stringWithFormat:@"%@ to: %@", [message objectForKey:@"sender"], [directRef objectForKey:@"name"]];
        [message setObject:@"true" forKey:@"lock"];
        [message setObject:@"true" forKey:@"lockColor"];
      }
      
      if (replyName && directRef == nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@", [message objectForKey:@"sender"], replyName];
      if (replyName && directRef != nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@", [message objectForKey:@"sender"], replyName];
      
      
      [message setObject:fromLine forKey:@"fromLine"];
    } @catch (NSException *theErr) {}
  }
  
  @synchronized ([UIApplication sharedApplication]) {  
    [FeedCache purgeOldFeeds];
    if (checkNew)
      self.olderAvailable = [FeedCache writeCheckNew:feed
                    messages:[NSMutableArray arrayWithArray:tempMessages] 
                    more:olderAvailable
                    useLatestReply:showReplyCounts];
    else
      [FeedCache writeFetchMore:feed
                  messages:[NSMutableArray arrayWithArray:tempMessages] 
                      more:olderAvailable
                      useLatestReply:showReplyCounts];
  }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (olderAvailable && [fetcher.fetchedObjects count] < MAX_FEED_CACHE)
    return 2;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
  	return [[fetcher sections] count];
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];

    if (cell == nil)
      cell = [[[MessageCell alloc] init] autorelease];
    
    Message *message = [fetcher.fetchedObjects objectAtIndex:indexPath.row];
    
    [cell setMessage:message showReplyCounts:showReplyCounts];
    return cell;
  } else if (indexPath.section == 1) {
    SpinnerCell *cell = (SpinnerCell *)[tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
	  if (cell == nil) {
		  cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero 
                                   reuseIdentifier:@"MoreCell"
                                   spinRect:CGRectMake(60, 12, 20, 20)
                                   textRect:CGRectMake(100, 12, 200, 20)] autorelease];
    }
    
    [cell displayMore];
    [cell hideSpinner];
  	return cell;
  } else if (indexPath.section == 3) {
    SpinnerCell *cell = (SpinnerCell *)[tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
	  if (cell == nil) {
		  cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero 
                                 reuseIdentifier:@"StatusCell"
                                        spinRect:CGRectMake(60, 4, 20, 20)
                                        textRect:CGRectMake(100, 4, 200, 20)] autorelease];
      [cell showSpinner];
      [cell displayCheckNew];
    }
    
    cell.displayText.font = [UIFont systemFontOfSize:12];
  	return cell;
  }
  return nil;
}   

- (void)dealloc {
  [messages release];
  [feed release];
  [fetcher release];
  [context release];
  [super dealloc];
}

@end
