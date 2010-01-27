#import "APIGateway.h"
#import "OAuthGateway.h"
#import "NSString+SBJSON.h"
#import "LocalStorage.h"
#import "OAuthPostURLEncoded.h"
#import "OAuthPostMultipart.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "YammerAppDelegate.h"
#import "AutoCompleteCache.h"

@implementation APIGateway

+ (NSMutableDictionary *)usersCurrent:(NSString *)style {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/users/current.json" style:style];
  
  if (json) {
    NSMutableDictionary* current = (NSMutableDictionary*)[json JSONValue];    
    yammer.network_id = [current objectForKey:@"network_id"];
    [LocalStorage saveSetting:@"current_network_id" value:yammer.network_id];
    [LocalStorage saveFile:[APIGateway user_file] data:json];
    [LocalStorage removeFile:[APIGateway push_file]];
    return current;
  }
  
  return nil;
}

+ (NSMutableArray *)homeTabs {
  
  NSString *cached = [LocalStorage getFile:[APIGateway user_file]];
  if (cached) {
    NSMutableDictionary *dict = [(NSMutableDictionary *)[cached JSONValue] objectForKey:@"web_preferences"];
    return (NSMutableArray*)[dict objectForKey:@"home_tabs"];
  }
  
  return nil;
}

+ (NSString*)user_file_with_id:(long)theid {
  return [NSString stringWithFormat:@"account/users_current_%d.json", theid];
}

+ (NSString*)push_file_with_id:(long)theid {
  return [NSString stringWithFormat:@"account/push_%d.json", theid];
}

+ (NSString*)push_file {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  return [APIGateway push_file_with_id:[yammer.network_id longValue]];
}

+ (NSString*)user_file {
  YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  return [APIGateway user_file_with_id:[yammer.network_id longValue]];
}

+ (NSMutableDictionary *)pushSettings:(NSString*)style {
  NSString *json = [OAuthGateway httpGet:@"/api/v1/feed_clients.json" style:style];
  if (json) {
    NSMutableArray *clients = (NSMutableArray *)[json JSONValue];
    int i=0; 
    for (; i<[clients count]; i++) {
      NSMutableDictionary *client = [clients objectAtIndex:i];
      if ([[client objectForKey:@"type"] isEqualToString:@"ApplePushDevice"]) {        
        json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/feed_clients/%@.json", [[client objectForKey:@"id"] description]] style:style];
        if (json) {
          [LocalStorage saveFile:[APIGateway push_file] data:json];
          return (NSMutableDictionary *)[json JSONValue];
        }
      }
    }
  }
  
  return nil;
}

+ (NSMutableArray *)users:(int)page style:(NSString *)style {

  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/users.json?page=%d", page] style:style];
  
  if (json) {
    if (page == 1)
      [LocalStorage saveFile:DIRECTORY_CACHE data:json];
    return (NSMutableArray *)[json JSONValue];
  }
  
  return nil;
}

+ (NSMutableDictionary *)userById:(NSString *)theUserId {
  
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/users/%@.json", theUserId] style:nil];
    
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (NSMutableDictionary*)autocomplete:(NSString*)prefix {	
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/autocomplete.json?prefix=%@", prefix] style:@"silent"];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

  if (json) {
		[AutoCompleteCache save:prefix data:json];
    return (NSMutableDictionary *)[json JSONValue];
	}
  
  return nil;  
}

+ (NSMutableDictionary *)messages:(FeedDictionary *)feed olderThan:(NSNumber *)olderThan style:(NSString *)style {
  return [APIGateway messages:feed olderThan:olderThan newerThan:nil style:style];
}

+ (NSMutableDictionary *)messages:(FeedDictionary *)feed newerThan:(NSNumber *)newerThan style:(NSString *)style {
  return [APIGateway messages:feed olderThan:nil newerThan:newerThan style:style];
}

+ (NSMutableDictionary *)messages:(FeedDictionary *)feed olderThan:(NSNumber*)olderThan 
                                                          newerThan:(NSNumber*)newerThan
                                                          style:(NSString*)style {
  
  NSString *url = [feed objectForKey:@"url"];

  NSMutableArray *params = [NSMutableArray array];
  
  if ([url hasSuffix:@"/following"] && olderThan == nil) 
    [params addObject:[NSString stringWithFormat:@"update_last_seen_message_id=%@", @"true"]];
  if (olderThan)
    [params addObject:[NSString stringWithFormat:@"older_than=%@", [olderThan description]]];
  if (newerThan)
    [params addObject:[NSString stringWithFormat:@"newer_than=%@", [newerThan description]]];

  if ([feed threading])
    [params addObject:[NSString stringWithFormat:@"threaded=%@", @"true"]];
  
  NSMutableString* paramString = [NSMutableString stringWithFormat:@"?"];
  for (int i=0; i<[params count]; i++) {
    [paramString appendString:[params objectAtIndex:i]];
    if (i < [params count] - 1)
      [paramString appendString:@"&"];
  }

//  NSLog(paramString);
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"%@.json%@", url, paramString] style:style];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (NSMutableArray*)networksCurrent:(NSString*)style {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/networks/current.json" style:style];

  if (json) {
    [LocalStorage saveFile:NETWORKS_CURRENT data:json];
    return (NSMutableArray *)[json JSONValue];
  }
  
  return nil;
}

+ (NSMutableArray*)getTokens {
  NSString *json = [OAuthGateway httpGet:@"/api/v1/oauth/tokens.json" style:nil];
  if (json) {
    [LocalStorage saveFile:TOKENS data:json];
    return (NSMutableArray *)[json JSONValue];
  }
  
  return nil;
}

+ (BOOL)createMessage:(NSString *)body repliedToId:(NSNumber *)repliedToId 
                                       groupId:(NSNumber *)groupId
                                       imageData:(NSData *)imageData {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:body forKey:@"body"];
  if (repliedToId)
    [params setObject:[repliedToId description] forKey:@"replied_to_id"];
  if (groupId)
    [params setObject:[groupId description] forKey:@"group_id"];

  if (imageData)
    return [OAuthPostMultipart makeHTTPConnection:params path:@"/api/v1/messages" data:imageData];
  else
    return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/messages" method:@"POST" style:nil];
}

+ (BOOL)followingUser:(NSString *)theUserId {
  return [OAuthGateway httpGet200vsError:[NSString stringWithFormat:@"/api/v1/subscriptions/to_user/%@", theUserId]];
}

+ (BOOL)removeFollow:(NSString *)theUserId {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:theUserId forKey:@"target_id"];
  [params setObject:@"User" forKey:@"target_type"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/subscriptions" method:@"DELETE" style:nil];    
}

+ (BOOL)addFollow:(NSString *)theUserId {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:theUserId forKey:@"target_id"];
  [params setObject:@"User" forKey:@"target_type"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/subscriptions" method:@"POST" style:nil];
}

+ (BOOL)sendPushToken:(NSString *)token {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:token forKey:@"feed_client[client_id]"];
  [params setObject:@"ApplePushDevice" forKey:@"feed_client[type]"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/feed_clients" method:@"POST" style:@"silent"];  
}

+ (BOOL)updatePushField:(NSString *)field value:(NSString *)value theId:(NSNumber *)theId pushSettings:(NSMutableDictionary*)pushSettings {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:value forKey:[NSString stringWithFormat:@"feed_client[%@]", field]];
  [params setObject:@"PUT" forKey:@"_method"];
  
  @synchronized ([UIApplication sharedApplication]) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([OAuthPostURLEncoded makeHTTPConnection:params path:[NSString stringWithFormat:@"/api/v1/feed_clients/%@", [theId description]] method:@"POST" style:nil])
      [LocalStorage saveFile:[APIGateway push_file] data:[pushSettings JSONRepresentation]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }
  return true;
}


+ (BOOL)updatePushSetting:(NSString *)feed_key status:(NSString *)statusValue theId:(NSNumber *)theId pushSettings:(NSMutableDictionary*)pushSettings {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:statusValue forKey:[NSString stringWithFormat:@"feed_client[notifications][%@]", feed_key]];
  [params setObject:@"PUT" forKey:@"_method"];
  
  @synchronized ([UIApplication sharedApplication]) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([OAuthPostURLEncoded makeHTTPConnection:params path:[NSString stringWithFormat:@"/api/v1/feed_clients/%@", [theId description]] method:@"POST" style:nil])
      [LocalStorage saveFile:[APIGateway push_file] data:[pushSettings JSONRepresentation]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }
  return true;
}

+ (BOOL)updatePushSettingsInBulk:(NSNumber *)theId pushSettings:(NSMutableDictionary*)pushSettings {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:[pushSettings objectForKey:@"protocol"] forKey:@"feed_client[protocol]"];
  if ([[pushSettings objectForKey:@"sleep_enabled"] boolValue])
    [params setObject:@"1" forKey:@"feed_client[sleep_enabled]"];
  else
    [params setObject:@"0" forKey:@"feed_client[sleep_enabled]"];
  [params setObject:[[pushSettings objectForKey:@"sleep_hour_start"] description] forKey:@"feed_client[sleep_hour_start]"];
  [params setObject:[[pushSettings objectForKey:@"sleep_hour_end"] description] forKey:@"feed_client[sleep_hour_end]"];
  
  NSMutableArray *notifications = [pushSettings objectForKey:@"notifications"];
  for (NSMutableDictionary* tab in notifications) {
    NSString *feed_key = [tab objectForKey:@"feed_key"];
    [params setObject:[tab objectForKey:@"status"] forKey:[NSString stringWithFormat:@"feed_client[notifications][%@]", feed_key]];    
  }
  
  [params setObject:@"PUT" forKey:@"_method"];
  return [OAuthPostURLEncoded makeHTTPConnection:params path:[NSString stringWithFormat:@"/api/v1/feed_clients/%@", [theId description]] method:@"POST" style:@"silent"];
}

+ (BOOL)likeMessage:(NSNumber *)message_id {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:[message_id description] forKey:@"message_id"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/messages/liked_by" method:@"POST" style:nil];
  return true;  
}

+ (BOOL)unlikeMessage:(NSNumber *)message_id {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:[message_id description] forKey:@"message_id"];
  [params setObject:@"DELETE" forKey:@"_method"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/messages/liked_by" method:@"POST" style:nil];
  return true;  
}


@end
