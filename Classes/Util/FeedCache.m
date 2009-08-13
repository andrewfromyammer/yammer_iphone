//
//  ImageCache.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedCache.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
#import "ImageCache.h"
#import "Message.h"
#import "FeedMetaData.h"
#import "YammerAppDelegate.h"

@implementation FeedCache


+ (NSString *)feedCacheUniqueID:(NSMutableDictionary *)feed {
  // http://23434234/api/v1/messages/wefwef
  // http://23434234/api/v1/messages
  // /api/v1/messages/wefwef
  // /api/v1/messages
  NSString *url = [feed objectForKey:@"url"];
  NSString *result = nil;
  
  NSRange range = [url rangeOfString:@"/messages"];
  
  if (range.location != NSNotFound)
    result = [url substringFromIndex:range.location+8];
  
  if ([LocalStorage threading] && [feed objectForKey:@"isThread"] == nil)
    result = [NSString stringWithFormat:@"%@ t", result];

  return result;
}

+ (void)purgeOldFeeds {
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedMetaData" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
  [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc]
                                                                     initWithKey:@"last_update" ascending:YES], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:@"last_update" 
                                                                                       cacheName:@"Root"];
  NSError *error;
	[fetcher performFetch:&error];
  
  if ([fetcher.fetchedObjects count] > 500) {
    FeedMetaData *fmd = [fetcher.fetchedObjects objectAtIndex:0];
    NSString *feedCopy = [NSString stringWithString:fmd.feed];
    [context deleteObject:fmd];
    [context save:&error];
    
    [FeedCache deleteOldMessages:feedCopy limit:false useLatestReply:false];
  }

  [fetcher release];
	[fetchRequest release];
  [context release];
}

+ (NSDate *)loadFeedDate:(NSMutableDictionary *)feed {
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedMetaData" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@", [FeedCache feedCacheUniqueID:feed]];
  [fetchRequest setPredicate:feedPredicate];
  [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc]
                                                                     initWithKey:@"feed" ascending:NO], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:@"feed" 
                                                                                       cacheName:@"Root"];
  NSError *error;
	[fetcher performFetch:&error];
  
  NSDate *date = nil;
  if ([fetcher.fetchedObjects count] == 1) {
    FeedMetaData *fmd = [fetcher.fetchedObjects objectAtIndex:0];
    date = [NSDate dateWithTimeIntervalSince1970:[fmd.last_update timeIntervalSince1970]];
  }
  
  [fetcher release];
	[fetchRequest release];
  [context release];
  
  return date;
}

+ (NSMutableDictionary *)updateLastReplyIds:(NSString *)feed messages:(NSMutableArray *)messages {
  // SELECT OUT ALL MESSAGES CURRENTLY IN DB FOR UPDATING:
  NSMutableArray *ids = [NSMutableArray array];
  NSMutableDictionary *counts = [NSMutableDictionary dictionary];
  int i=0;
  for (; i<[messages count]; i++) {
    NSMutableDictionary *dict = [messages objectAtIndex:i];
    [ids addObject:[[dict objectForKey:@"id"] description]];
    [counts setObject:dict forKey:[[dict objectForKey:@"id"] description]];
  }
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@ AND message_id IN %@", feed, ids];
  [fetchRequest setPredicate:feedPredicate];
	[fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc]
                                                                     initWithKey:@"message_id" ascending:NO], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:@"message_id" 
                                                                                       cacheName:@"Root"];  
  NSError *error;
	[fetcher performFetch:&error];
  
  NSMutableDictionary *id_lookup = [NSMutableDictionary dictionary];
  for (i=0; i<[fetcher.fetchedObjects count]; i++) {
    Message *m = [fetcher.fetchedObjects objectAtIndex:i];
    NSMutableDictionary *dict = [counts objectForKey:[m.message_id description]];
    m.latest_reply_id = [[NSNumber alloc] initWithLong:[[dict objectForKey:@"thread_latest_reply_id"] longValue]];
    m.thread_updates  = [[NSNumber alloc] initWithLong:[[dict objectForKey:@"thread_updates"] longValue]];
    [id_lookup setObject:@"true" forKey:[m.message_id description]];
  }  
  [context save:&error];
  
  [fetcher release];
	[fetchRequest release];
  [context release];
  [counts release];
  
  return id_lookup;
}

+ (void)deleteOldMessages:(NSString *)feed limit:(BOOL)limit useLatestReply:(BOOL)useLatestReply {
  NSString *order_by = @"message_id";
  if (useLatestReply)
    order_by = @"latest_reply_id";
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@", feed];
  [fetchRequest setPredicate:feedPredicate];
  if (limit)
    [fetchRequest setFetchOffset:MAX_FEED_CACHE];
  [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc]
                                                                     initWithKey:order_by ascending:NO], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:order_by 
                                                                                       cacheName:@"Root"];
  NSError *error;
	[fetcher performFetch:&error];
  
  int i;
  for (i=0; i<[fetcher.fetchedObjects count]; i++)
    [context deleteObject:[fetcher.fetchedObjects objectAtIndex:i]];
  [context save:&error];
  
  [fetcher release];
	[fetchRequest release];  
  [context release];

}

+ (BOOL)writeCheckNew:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply {

  if (olderAvailable) {
    // truncate entire feed
    [FeedCache deleteOldMessages:feed limit:false useLatestReply:false];
    // add messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // set more = true
    [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:@"true"];
    return true;
  } else {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[FeedCache updateLastReplyIds:feed messages:messages]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true useLatestReply:useLatestReply];
    // set more = orig
    return [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:nil];
  }
}

+ (void)writeFetchMore:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply {
  
  if (olderAvailable) {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true useLatestReply:useLatestReply];
    // set more = true
    [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:@"true"];
  } else {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true useLatestReply:useLatestReply];
    // set more = false
    [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:@"false"];
  }
}

+ (BOOL)createOrUpdateMetaData:(NSString *)feed updateOlderAvailable:(NSString *)older {
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedMetaData" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
  
  NSPredicate *feedPredicate = [NSPredicate predicateWithFormat:@"feed = %@", feed];
  [fetchRequest setPredicate:feedPredicate];
  [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc]
                                                                     initWithKey:@"feed" ascending:NO], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:@"feed" 
                                                                                       cacheName:@"Root"];
  NSError *error;
	[fetcher performFetch:&error];

  FeedMetaData *fmd = nil;
  int i;
  if ([fetcher.fetchedObjects count] > 1) {
    for (i=0; i<[fetcher.fetchedObjects count]; i++)
      [context deleteObject:[fetcher.fetchedObjects objectAtIndex:i]];
    fmd = (FeedMetaData *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedMetaData" 
                                                        inManagedObjectContext:context];
  } else if ([fetcher.fetchedObjects count] == 1)
    fmd = [fetcher.fetchedObjects objectAtIndex:0];
  else
    fmd = (FeedMetaData *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedMetaData" 
                                                          inManagedObjectContext:context];
  fmd.last_update = [NSDate date];
  fmd.network_id = yam.network_id;
  fmd.feed = feed;
  if (older && [older isEqualToString:@"true"])
    fmd.older_available = [[NSNumber alloc] initWithBool:true];
  else if (older && [older isEqualToString:@"false"])
    fmd.older_available = [[NSNumber alloc] initWithBool:false];

  BOOL return_val = [fmd.older_available boolValue];
  [context save:&error];
  
  [fetcher release];
	[fetchRequest release];
  [context release];
  
  return return_val;
}

+ (void)writeNewMessages:(NSString *)feed messages:(NSMutableArray *)messages lookup:(NSMutableDictionary *)lookup {
  
  //NSMutableDictionary *id_lookup = [FeedCache updateLastReplyIds:feed messages:messages];
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [yam managedObjectContext];
  
  int i;
  for (i=0; i<[messages count]; i++) {
    NSMutableDictionary *dict = [messages objectAtIndex:i];

    if ([lookup objectForKey:[[dict objectForKey:@"id"] description]])
      continue;
    
  	Message *m = (Message *)[NSEntityDescription insertNewObjectForEntityForName:@"Message" 
                                                 inManagedObjectContext:context];
    m.from = [dict objectForKey:@"fromLine"];
    
    NSMutableDictionary *body = [dict objectForKey:@"body"];
    m.plain_body = [body objectForKey:@"plain"];
        
    NSString *createdAt = [dict objectForKey:@"created_at"];
    NSString *front = [createdAt substringToIndex:10];
    NSString *end = [[createdAt substringFromIndex:11] substringToIndex:8];
    m.created_at = [NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ -0000", front, end]];
    m.feed = feed;
    m.message_id = [[NSNumber alloc] initWithLong:[[dict objectForKey:@"id"] longValue]];
    m.network_id = yam.network_id;
    m.latest_reply_id = [[NSNumber alloc] initWithLong:[[dict objectForKey:@"thread_latest_reply_id"] longValue]];
        
    if ([dict objectForKey:@"lock"])
      m.privacy = [[NSNumber alloc] initWithBool:YES];
    
    m.actor_id = [[NSNumber alloc] initWithLong:[[dict objectForKey:@"actor_id"] longValue]];
    m.actor_type = [dict objectForKey:@"actor_type"];
    m.actor_mugshot_url = [dict objectForKey:@"actor_mugshot_url"];
    m.group_full_name = [dict objectForKey:@"group_full_name"];
    m.attachments_json = [[dict objectForKey:@"attachments"] JSONRepresentation];
    m.sender = [dict objectForKey:@"sender"];
    m.thread_url = [dict objectForKey:@"thread_url"];
    m.thread_updates = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"thread_updates"] intValue]];
  }

  NSError *error;
  [context save:&error];  
  [context release];

}

+ (NSString *)niceDate:(NSDate *)date {
  if (!date) {
    return @"Network out of range.";
  }
  
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"MMM d YYYY"];
  if ([[outputFormatter stringFromDate:date] isEqualToString:[outputFormatter stringFromDate:[NSDate date]]]) {
    [outputFormatter setDateFormat:@"h:mm a"];
    return [NSString stringWithFormat:@"Updated %@ Today", [outputFormatter stringFromDate:date]];
  }
  
  [outputFormatter setDateFormat:@"h:mm a MMM d"];
  return [NSString stringWithFormat:@"Updated %@", [outputFormatter stringFromDate:date]];
}


@end
