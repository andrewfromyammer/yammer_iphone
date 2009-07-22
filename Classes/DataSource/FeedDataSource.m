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
#import "MessageTableCell.h"
#import "NSDate-Ago.h"
#import "FeedCache.h"
#import "SpinnerCell.h"

@implementation FeedDataSource

@synthesize messages;
@synthesize olderAvailable;
@synthesize fetchingMore;

+ (FeedDataSource *)getMessages:(NSMutableDictionary *)feed {
  
  NSMutableDictionary *dict = [FeedCache loadFeed:[feed objectForKey:@"url"]];
  
  if (dict) {
    BOOL olderAvailable = [[[dict objectForKey:@"meta"] objectForKey:@"olderAvailable"] isEqualToString:@"t"]; 

    return [[FeedDataSource alloc] initWithMessages:[dict objectForKey:@"messages"] feed:feed more:olderAvailable];
  }
  
  dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:nil];
  if (dict)
    return [[FeedDataSource alloc] initWithDict:dict feed:feed];
  
  dict = [NSMutableDictionary dictionary];
  [dict setObject:[NSMutableArray array] forKey:@"references"];
  [dict setObject:[NSMutableArray array] forKey:@"messages"];
  [dict setObject:[NSMutableDictionary dictionary] forKey:@"meta"];
  return [[FeedDataSource alloc] initWithDict:dict feed:feed];
}

- (id)initWithDict:(NSMutableDictionary *)dict feed:(NSMutableDictionary *)feed {
  self.messages = [NSMutableArray array];
  [self.messages addObjectsFromArray:[self proccesMessages:dict feed:feed]];
  [self processImages];
  return self;
}

- (id)initWithMessages:(NSMutableArray *)cachedMessages feed:(NSMutableDictionary *)feed more:(BOOL)hasMore {
  self.messages = cachedMessages;
  [self processImages];
  self.olderAvailable = hasMore;
  [NSThread detachNewThreadSelector:@selector(checkForNewerMessages:) toTarget:self withObject:feed];
  return self;
}

- (void)checkForNewerMessages:(NSMutableDictionary *)feed {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];

  NSMutableDictionary *message = [self.messages objectAtIndex:0];
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] newerThan:[message objectForKey:@"id"]];
  [self proccesMessages:dict feed:feed];
  
  [autoreleasepool release];
}

- (NSMutableArray *)proccesMessages:(NSMutableDictionary *)dict feed:(NSMutableDictionary *)feed {
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
        
        referencesById = [referencesByType objectForKey:@"thread"];
        NSMutableDictionary *threadRef = [referencesById objectForKey:[message objectForKey:@"thread_id"]];
        
        [message setObject:[threadRef objectForKey:@"web_url"] forKey:@"thread_url"];
        [message setObject:[threadRef objectForKey:@"updates"] forKey:@"thread_updates"];
      }
      
      referencesById = [referencesByType objectForKey:@"group"];
      NSMutableDictionary *groupRef = [referencesById objectForKey:[message objectForKey:@"group_id"]];
      
      if (groupRef) {
        [message setObject:[groupRef objectForKey:@"name"] forKey:@"group_name"];
        [message setObject:[groupRef objectForKey:@"privacy"] forKey:@"group_privacy"];
        if ([[groupRef objectForKey:@"privacy"] isEqualToString:@"private"]) {
          [message setObject:[NSString stringWithFormat:@"%@ (private)", [groupRef objectForKey:@"name"]] forKey:@"group_name"];
          [message setObject:@"true" forKey:@"lock"];
        }
      }
      
      referencesById = [referencesByType objectForKey:@"user"];
      NSMutableDictionary *directRef = [referencesById objectForKey:[message objectForKey:@"direct_to_id"]];
      
      NSString *fromLine  = [message objectForKey:@"sender"];
      NSString *replyName = [message objectForKey:@"reply_name"];
      
      if (directRef) {
        fromLine = [NSString stringWithFormat:@"%@ to: %@ (Private)", [message objectForKey:@"sender"], [directRef objectForKey:@"name"]];
        [message setObject:@"true" forKey:@"lock"];
        [message setObject:@"true" forKey:@"lockColor"];
      }
      
      if (replyName && directRef == nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@", [message objectForKey:@"sender"], replyName];
      if (replyName && directRef != nil)
        fromLine = [NSString stringWithFormat:@"%@ re: %@ (Private)", [message objectForKey:@"sender"], replyName];
      
      
      [message setObject:fromLine forKey:@"fromLine"];
      
      NSString *createdAt = [message objectForKey:@"created_at"];
      NSString *front = [createdAt substringToIndex:10];
      NSString *end = [[createdAt substringFromIndex:11] substringToIndex:8];
      
      NSString *timeLine = [[NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ -0000", front, end]] agoDate];    
      NSString *groupName = [message objectForKey:@"group_name"];
      if (groupName)
        timeLine = [NSString stringWithFormat:@"%@ in %@", timeLine, groupName];
      [message setObject:timeLine forKey:@"timeLine"];
    } @catch (NSException *theErr) {}
  }    

  [FeedCache writeFeed:[feed objectForKey:@"url"] messages:tempMessages more:self.olderAvailable];
 
  return tempMessages;
}

- (void)processImages {
  int i=0;
  for (i=0; i < [self.messages count]; i++) {
    @try {
      NSMutableDictionary *message = [self.messages objectAtIndex:i];
      
      [message setObject:[ImageCache getImageAndSave:[message objectForKey:@"actor_mugshot_url"] 
                                             user_id:[message objectForKey:@"actor_id"] 
                                                type:[message objectForKey:@"actor_type"]] forKey:@"imageData"];
    } @catch (NSException *theErr) {}
  }  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (olderAvailable)
    return 2;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
  	return [messages count];
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    MessageTableCell *cell = (MessageTableCell *)[tableView dequeueReusableCellWithIdentifier:@"FeedMessageCell"];

    if (cell == nil) {
      cell = [[[MessageTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedMessageCell"] autorelease];
    }
    
    NSMutableDictionary *message = [messages objectAtIndex:indexPath.row];
    cell.imageView.image = [[UIImage alloc] initWithData:[message objectForKey:@"imageData"]];
    [cell setMessage:message];

    return cell;
  } else {
    SpinnerCell *cell = (SpinnerCell *)[tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
	  if (cell == nil)
		  cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MoreCell"] autorelease];
    
    [cell.displayText setText:@"        More"];
  	return cell;
  }
}

- (void)dealloc {
  [messages release];
  [super dealloc];
}

@end
