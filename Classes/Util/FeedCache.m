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


+ (NSString *)feedCacheUniqueID:(NSString *)url {
  // http://23434234/api/v1/messages/wefwef
  // http://23434234/api/v1/messages
  // /api/v1/messages/wefwef
  // /api/v1/messages
  
  NSRange range = [url rangeOfString:@"/messages"];
  
  if (range.location != NSNotFound)
    return [url substringFromIndex:range.location+8];

  return nil;
}


+ (NSString *)feedCacheFilePath:(NSString *)url {
  NSString *file;
  
  if (![url hasPrefix:@"http"])
    file = [NSString stringWithFormat:@"%@%@", [OAuthGateway baseURL], url];
  else
    file = [NSString stringWithFormat:@"%@", url];
  
  file = [file stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
  file = [file stringByReplacingOccurrencesOfString:@":" withString:@"_"];
  file = [file stringByReplacingOccurrencesOfString:@"." withString:@"_"];
  
  NSString *suffix = @"";
  if ([LocalStorage threadedMode])
    suffix = @".t";
  
  return [[LocalStorage localPath] stringByAppendingPathComponent: 
          [NSString stringWithFormat:@"%@/%@%@", [LocalStorage feedDirectory], file, suffix]];  
}

+ (NSDate *)loadFeedDate:(NSString *)url {
  NSString *path = [FeedCache feedCacheFilePath:url];  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if ([fileManager fileExistsAtPath:path]) {    
    NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:path traverseLink:YES];
    return (NSDate *)[fileAttributes objectForKey:NSFileModificationDate];
  }
  return nil;
}


+ (NSMutableDictionary *)loadFeed:(NSString *)url {
  NSString *path = [FeedCache feedCacheFilePath:url];  
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath:path]) {
    return (NSMutableDictionary*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                               encoding:NSUTF8StringEncoding] JSONValue];
  }
  return nil;
}

+ (NSMutableDictionary *)updateLastReplyIds:(NSString *)feed messages:(NSMutableArray *)messages {
  // SELECT OUT ALL MESSAGES CURRENTLY IN DB FOR UPDATING:
  NSMutableArray *ids = [NSMutableArray array];
  int i=0;
  for (; i<[messages count]; i++) {
    NSMutableDictionary *dict = [messages objectAtIndex:i];
    [ids addObject:[[dict objectForKey:@"id"] description]];
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
    [id_lookup setObject:@"true" forKey:[m.message_id description]];
  }  
  
  [fetcher release];
	[fetchRequest release];
  
  return id_lookup;
}

+ (void)deleteOldMessages:(NSString *)feed limit:(BOOL)limit {  
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
                                                                     initWithKey:@"message_id" ascending:NO], nil]];
  
	NSFetchedResultsController *fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                            managedObjectContext:context 
                                                                              sectionNameKeyPath:@"message_id" 
                                                                                       cacheName:@"Root"];
  NSError *error;
	[fetcher performFetch:&error];
  
  int i;
  for (i=0; i<[fetcher.fetchedObjects count]; i++)
    [context deleteObject:[fetcher.fetchedObjects objectAtIndex:i]];
  [context save:&error];
  
  [fetcher release];
	[fetchRequest release];  
}

+ (BOOL)writeCheckNew:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {

  if (olderAvailable) {
    // truncate entire feed
    [FeedCache deleteOldMessages:feed limit:false];
    // add messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // set more = true
    [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:@"true"];
    return true;
  } else {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true];
    // set more = orig
    return [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:nil];
  }
}

+ (void)writeFetchMore:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {
  
  if (olderAvailable) {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true];
    // set more = true
    [FeedCache createOrUpdateMetaData:feed updateOlderAvailable:@"true"];
  } else {
    // update existing messages
    // add new messages
    [FeedCache writeNewMessages:feed messages:messages lookup:[NSMutableDictionary dictionary]];
    // delete old ones past limit
    [FeedCache deleteOldMessages:feed limit:true];
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

  [context save:&error];
  
  [fetcher release];
	[fetchRequest release];
  
  return [fmd.older_available boolValue];
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
    m.latest_reply_id = [[NSNumber alloc] initWithLong:23423];
    m.privacy   = [[NSNumber alloc] initWithBool:NO];
  }

  NSError *error;
  [context save:&error];  
}

+ (BOOL)writeFeed2:(NSString *)url messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {
  [ImageCache deleteOldestFile:[NSString stringWithFormat:@"%@%@", [LocalStorage localPath], [LocalStorage feedDirectory]]];
  
  NSString *path = [FeedCache feedCacheFilePath:url];    
  NSFileManager *fileManager = [NSFileManager defaultManager];  
  if ([fileManager fileExistsAtPath:path]) {
    NSMutableDictionary *dict = (NSMutableDictionary*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                                                       encoding:NSUTF8StringEncoding] JSONValue];
    NSMutableArray *existing = [dict objectForKey:@"messages"];
    BOOL existingOlderAvailable = [[[dict objectForKey:@"meta"] objectForKey:@"olderAvailable"] isEqualToString:@"t"];
    
    if ([messages count] == 0) {
      [FeedCache trimArrayAndWrite:path messages:existing more:existingOlderAvailable];
      return false;
    }
    
    if ([existing count] == 0) {
      [FeedCache trimArrayAndWrite:path messages:messages more:olderAvailable];
      return false;
    }
    
    NSMutableDictionary *lastNew       = [messages lastObject];
    NSMutableDictionary *firstNew      = [messages objectAtIndex:0];
    NSMutableDictionary *firstExisting = [existing objectAtIndex:0];
    NSMutableDictionary *lastExisting  = [existing lastObject];    

    if ([[lastNew objectForKey:@"id"] intValue] > [[firstExisting objectForKey:@"id"] intValue]) {
      
      // make another http call here for the next twenty, older than the last id
      // if our existing first id is within that next batch, line 'er up
      // if not, delete all the existing, just have 40 cached.
      
      if (olderAvailable) {
        [FeedCache trimArrayAndWrite:path messages:messages more:true];
        return true;
      } else {
        [messages addObjectsFromArray:existing];
        [FeedCache trimArrayAndWrite:path messages:messages more:existingOlderAvailable];
      }
    }
    else if ([[lastExisting objectForKey:@"id"] intValue] > [[firstNew objectForKey:@"id"] intValue]) {
      [existing addObjectsFromArray:messages];
      [FeedCache trimArrayAndWrite:path messages:existing more:olderAvailable];
    }
  } else
    [FeedCache trimArrayAndWrite:path messages:messages more:olderAvailable];
  return false;
}

+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {  
  NSFileManager *fileManager = [NSFileManager defaultManager];  

  NSRange range;
  range.location = MAX_FEED_CACHE;
  range.length = [messages count] - MAX_FEED_CACHE;
  if ([messages count] > MAX_FEED_CACHE) {
    olderAvailable = true;
    [messages removeObjectsInRange:range];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:messages forKey:@"messages"];
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  if (olderAvailable)
    [meta setObject:@"t" forKey:@"olderAvailable"];
  else
    [meta setObject:@"f" forKey:@"olderAvailable"];
  
  [dict setObject:meta forKey:@"meta"];
  [fileManager createFileAtPath:path contents:[[dict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+ (NSString *)niceDate:(NSDate *)date {
  if (date == nil) {
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
