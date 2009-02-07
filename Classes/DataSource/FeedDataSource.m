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

@implementation FeedDataSource

@synthesize messages;
@synthesize olderAvailable;

+ (FeedDataSource *)getMessages:(NSMutableDictionary *)feed {
  NSMutableDictionary *dict = [APIGateway messages:[feed objectForKey:@"url"] olderThan:nil];
  if (dict)
    return [[FeedDataSource alloc] initWithDict:dict];
  
  dict = [NSMutableDictionary dictionary];
  [dict setObject:[NSMutableArray array] forKey:@"references"];  
  [dict setObject:[NSMutableArray array] forKey:@"messages"];
  [dict setObject:[NSMutableDictionary dictionary] forKey:@"meta"];
  return [[FeedDataSource alloc] initWithDict:dict];
}

- (id)initWithDict:(NSMutableDictionary *)dict {
  self.messages = [NSMutableArray array];
  [self proccesMessages:dict];
  return self;
}

- (void)proccesMessages:(NSMutableDictionary *)dict {
  NSMutableDictionary *meta = [dict objectForKey:@"meta"];
  NSNumber *older = [meta objectForKey:@"older_available"];
  self.olderAvailable = false;
  if (older && [older intValue] == 1)
    self.olderAvailable = true;
  
  NSMutableArray *references = [dict objectForKey:@"references"];
  
  NSMutableDictionary *referencesByType = [NSMutableDictionary dictionary];
  
  int i=0;
  for (; i < [references count]; i++) {
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

  i=0;
  for (; i < [tempMessages count]; i++) {
    NSMutableDictionary *message = [tempMessages objectAtIndex:i];
    NSMutableDictionary *referencesById = [referencesByType objectForKey:[message objectForKey:@"sender_type"]];
    NSMutableDictionary *userOrGuide = [referencesById objectForKey:[message objectForKey:@"sender_id"]];
    
    [message setObject:[userOrGuide objectForKey:@"name"] forKey:@"sender"];    
    [message setObject:[ImageCache getImageAndSave:[userOrGuide objectForKey:@"mugshot_url"] user_id:[userOrGuide objectForKey:@"id"] type:[userOrGuide objectForKey:@"type"]] forKey:@"imageData"];
    
    referencesById = [referencesByType objectForKey:@"message"];
    NSMutableDictionary *messageRef = [referencesById objectForKey:[message objectForKey:@"replied_to_id"]];
    
    if (messageRef) {
      referencesById = [referencesByType objectForKey:[messageRef objectForKey:@"sender_type"]];
      NSMutableDictionary *userOrGuide = [referencesById objectForKey:[messageRef objectForKey:@"sender_id"]];
      
      [message setObject:[userOrGuide objectForKey:@"name"] forKey:@"reply_name"];

      referencesById = [referencesByType objectForKey:@"thread"];
      NSMutableDictionary *threadRef = [referencesById objectForKey:[message objectForKey:@"thread_id"]];

      [message setObject:[threadRef objectForKey:@"web_url"] forKey:@"thread_url"];
    }

    referencesById = [referencesByType objectForKey:@"group"];
    NSMutableDictionary *groupRef = [referencesById objectForKey:[message objectForKey:@"group_id"]];
    
    if (groupRef)
      [message setObject:[groupRef objectForKey:@"name"] forKey:@"group_name"];
    
    NSString *fromLine  = [message objectForKey:@"sender"];
    NSString *replyName = [message objectForKey:@"reply_name"];
    if (replyName)
      fromLine = [NSString stringWithFormat:@"%@ re: %@", fromLine, replyName];
    [message setObject:fromLine forKey:@"fromLine"];
    
    NSString *createdAt = [message objectForKey:@"created_at"];
    NSString *front = [createdAt substringToIndex:10];
    NSString *end = [[createdAt substringFromIndex:11] substringToIndex:8];
    
    NSString *timeLine = [[NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ -0000", front, end]] agoDate];    
    NSString *groupName = [message objectForKey:@"group_name"];
    if (groupName)
      timeLine = [NSString stringWithFormat:@"%@ in %@", timeLine, groupName];
    [message setObject:timeLine forKey:@"timeLine"];
  }    
  [self.messages addObjectsFromArray:tempMessages];
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
    cell.image = [[UIImage alloc] initWithData:[message objectForKey:@"imageData"]];
    [cell setMessage:message];

    return cell;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
	  if (cell == nil)
		  cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MoreCell"] autorelease];
    
    cell.text = @"                fetch more";
    cell.textColor = [UIColor blueColor];
  	return cell;
  }
}

- (void)dealloc {
  [messages release];
  [super dealloc];
}

@end
