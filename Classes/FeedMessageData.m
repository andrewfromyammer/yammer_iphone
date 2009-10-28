#import "FeedMessageData.h"
#import "TTTableYammerItemCell.h"
#import "TTTableYammerItem.h"
#import "Message.h"
#import "YammerAppDelegate.h"
#import "FeedCache.h"
#import "LocalStorage.h"
#import "UserProfile.h"

@implementation FeedMessageData

@synthesize feed, nameField = _nameField, colorTheseMessageIDs = _colorTheseMessageIDs, feedDictionary = _feedDictionary;

+ (FeedMessageData*)feed:(FeedDictionary *)theFeed {
  NSArray* items = [NSArray array];
  return [[[self alloc] initWithFeed:theFeed items:items] autorelease];
}

- (id)initWithFeed:(FeedDictionary *)theFeed items:(NSArray*)items {
  if (self = [self init]) {
    _items = [items mutableCopy];
    self.feed = [FeedCache feedCacheUniqueID:theFeed];
    self.feedDictionary = theFeed;
    self.nameField = [LocalStorage getNameField];
    self.colorTheseMessageIDs = [NSMutableDictionary dictionary];
  }
  return self;
}

- (int)count {
  return [_items count] - 1;
}

- (NSMutableDictionary*)firstItem {
  return ((TTTableYammerItem*)[_items objectAtIndex:1]).message;
}

- (NSMutableDictionary*)lastObject {
  return ((TTTableYammerItem*)[_items lastObject]).message;
}

- (SpinnerWithTextItem*)spinnerItem {
  return (SpinnerWithTextItem*)[_items objectAtIndex:0];
}

- (NSMutableDictionary*)objectAtIndex:(int)index {
  return ((TTTableYammerItem*)[_items objectAtIndex:index]).message;
}

- (void)fetch:(NSNumber *)offset {
  NSString *order_by = @"message_id";
  if ([_feedDictionary threading])
    order_by = @"latest_reply_id";
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:[yam managedObjectContext]];
	[fetchRequest setEntity:entity];
  [fetchRequest setFetchOffset:0];
  if (offset)
    [fetchRequest setFetchOffset:[offset intValue]];
  [fetchRequest setFetchLimit:20];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@ and network_id = %@", feed, [yam.network_id description]];
  [fetchRequest setPredicate:feedPredicate];
  
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:order_by ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                     managedObjectContext:[yam managedObjectContext] 
                                                       sectionNameKeyPath:order_by 
                                                                cacheName:@"Root"];
  
  NSError *error;
	if (![fetcher performFetch:&error]) {
    NSLog(@"error %@", [error description]);
  }
  
  int i=0;
  for (; i<[fetcher.fetchedObjects count]; i++) {
    Message* m = [fetcher.fetchedObjects objectAtIndex:i];
    NSMutableDictionary* safeMessage = [m safeMessage];
    
    long compareId = [m.message_id longValue];
    if ([_feedDictionary threading])
      compareId = [m.latest_reply_id longValue];
    
    if (yam.last_seen_message_id > 0 && compareId > yam.last_seen_message_id)
      [safeMessage setObject:[UIColor colorWithRed:0.85 green:1.0 blue:0.95 alpha:1.0] forKey:@"fill"];

    TTTableYammerItem* item = [TTTableYammerItem itemWithMessage:safeMessage];
    item.threading = [_feedDictionary threading];
    if ([[safeMessage objectForKey:@"thread_updates"] intValue] < 1)
      item.threading = NO;
    item.feedIsThread = [_feedDictionary objectForKey:@"isThread"] != nil;
    [_items addObject:item];
  }

}

- (void)dealloc {
  [feed release];
  TT_RELEASE_SAFELY(_nameField);
  TT_RELEASE_SAFELY(_colorTheseMessageIDs);
  TT_RELEASE_SAFELY(_feedDictionary);
  [super dealloc];
}

- (void)removeAllColor {
  for (int i=1; i<[_items count]; i++) {
    TTTableYammerItem* item = [_items objectAtIndex:i];
    [item.message removeObjectForKey:@"fill"];
  }
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[TTTableMoreButton class]])
      return [TTTableMoreButtonCell class];
  else if ([object isKindOfClass:[SpinnerWithTextItem class]])
    return [SpinnerWithTextCell class];
  return [TTTableYammerItemCell class];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([_items count] >= [FeedCache maxSize])
    return 1;
  
  if ([_items count] <= 1)
    return 1;
  
  FeedMetaData *fmd = nil;
  @synchronized ([UIApplication sharedApplication]) {  
    fmd = [FeedCache loadFeedMeta:feed];
  }
  NSMutableDictionary *m = [self lastObject];
  if ([[m objectForKey:@"message_id"] intValue] != [fmd.last_message_id intValue])
    return 2;
  
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return _items.count;
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return nil;
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  
  if (indexPath.section == 0)
    return [_items objectAtIndex:indexPath.row];

  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

  int n = yam.unseen_message_count_following - (_items.count - 1);
  if (n > 0)
    return [TTTableMoreButton itemWithText:[NSString stringWithFormat:@"    Show %d more new messages", n]];
  return [TTTableMoreButton itemWithText:@"                       More"];
}

- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  NSUInteger index = [_items indexOfObject:object];
  if (index != NSNotFound) {
    return [NSIndexPath indexPathForRow:index inSection:0];
  }  
  return nil;
}

- (NSMutableDictionary*)proccesMessages:(NSMutableDictionary *)dict checkNew:(BOOL)checkNew newerThan:(NSNumber *)newerThan {
  
  NSMutableDictionary *meta = [dict objectForKey:@"meta"];
  NSNumber *older = [meta objectForKey:@"older_available"];  
  BOOL olderAvailable = false;
  if (older && [older intValue] == 1)
    olderAvailable = true;
  
  NSMutableDictionary *liked_ids = [NSMutableDictionary dictionary];
  int i=0;
  for (i=0; i < [[meta objectForKey:@"liked_message_ids"] count]; i++)
    [liked_ids setObject:@"1" forKey:[[[meta objectForKey:@"liked_message_ids"] objectAtIndex:i] description]];
    
  NSMutableArray *references = [dict objectForKey:@"references"];
  
  NSMutableDictionary *referencesByType = [NSMutableDictionary dictionary];
  
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
  NSMutableDictionary* ids = [NSMutableDictionary dictionary];

  for (i=0; i < [tempMessages count]; i++) {
    @try {
      NSMutableDictionary *message = [tempMessages objectAtIndex:i];
      [ids setObject:@"1" forKey:[[message objectForKey:@"id"] description]];
      NSMutableDictionary *referencesById = [referencesByType objectForKey:[message objectForKey:@"sender_type"]];
      NSMutableDictionary *actor = [referencesById objectForKey:[message objectForKey:@"sender_id"]];
      
      [message setObject:[actor objectForKey:@"mugshot_url"] forKey:@"actor_mugshot_url"];
      [message setObject:[actor objectForKey:@"id"] forKey:@"actor_id"];
      [message setObject:[actor objectForKey:@"type"] forKey:@"actor_type"];
      
      [message setObject:[UserProfile safeName:actor] forKey:@"sender"];
      
      referencesById = [referencesByType objectForKey:@"message"];
      NSMutableDictionary *messageRef = [referencesById objectForKey:[message objectForKey:@"replied_to_id"]];
      
      if (messageRef) {
        referencesById = [referencesByType objectForKey:[messageRef objectForKey:@"sender_type"]];
        NSMutableDictionary *actor = [referencesById objectForKey:[messageRef objectForKey:@"sender_id"]];
        
        [message setObject:[UserProfile safeName:actor] forKey:@"reply_name"];
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
                
        fromLine = [NSString stringWithFormat:@"%@ to: %@", [message objectForKey:@"sender"], [UserProfile safeName:directRef]];
        [message setObject:@"true" forKey:@"lock"];
        [message setObject:@"true" forKey:@"lockColor"];
      }
      
      if (replyName && directRef == nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@", [message objectForKey:@"sender"], replyName];
      if (replyName && directRef != nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@", [message objectForKey:@"sender"], replyName];
      
      
      [message setObject:fromLine forKey:@"fromLine"];
            
      NSMutableDictionary *likedDict = [message objectForKey:@"liked_by"];
      [message setObject:[likedDict objectForKey:@"count"] forKey:@"likes"];
      
      if ([liked_ids objectForKey:[[message objectForKey:@"id"] description]])
        [message setObject:@"1" forKey:@"liked_by_me"];
      
    } @catch (NSException *theErr) {}
  }
    
  @synchronized ([UIApplication sharedApplication]) {
    YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
    @try {
      if ([[_feedDictionary objectForKey:@"url"] hasSuffix:@"/following"] && checkNew) {
        yam.unseen_message_count_following = [[meta objectForKey:@"unseen_message_count_following"] intValue];
        yam.unseen_message_count_received = [[meta objectForKey:@"unseen_message_count_received"] intValue];
        yam.last_seen_message_id = [[meta objectForKey:@"last_seen_message_id"] longValue];
      }
    } @catch (NSException *err) { }
    
    if (checkNew) {
      if (newerThan == nil && olderAvailable == false)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:[[tempMessages lastObject] objectForKey:@"id"]];
      else if (newerThan == nil && olderAvailable == true)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:[NSNumber numberWithInt:0]];
      else if (newerThan != nil && olderAvailable == false)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:nil];
      else if (newerThan != nil && olderAvailable == true)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:[NSNumber numberWithInt:0]];
    }
    else {
      if (olderAvailable == false)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:[[tempMessages lastObject] objectForKey:@"id"]];
      else if (olderAvailable == true)
        [FeedCache createOrUpdateMetaData:feed lastMessageId:[NSNumber numberWithInt:0]];
    }
    
    if ([tempMessages count] > 0)
      [FeedCache purgeOldFeeds];
    if (checkNew)
      [FeedCache writeCheckNew:feed
                      messages:[NSMutableArray arrayWithArray:tempMessages] 
                          more:olderAvailable
                useLatestReply:false];
    else
      [FeedCache writeFetchMore:feed
                       messages:[NSMutableArray arrayWithArray:tempMessages] 
                           more:olderAvailable
                 useLatestReply:false];
  }
  
  
  return ids;
}

@end
