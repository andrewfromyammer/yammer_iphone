//
//  APIGateway.m
//  Yammer
//
//  Created by aa on 1/29/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "APIGateway.h"
#import "OAuthGateway.h"
#import "NSString+SBJSON.h"
#import "LocalStorage.h"
#import "OAuthPostURLEncoded.h"
#import "OAuthPostMultipart.h"
#import "NSString+SBJSON.h"

@implementation APIGateway

+ (NSMutableDictionary *)usersCurrent:(NSString *)style {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/users/current.json" style:style];
  
  if (json) {
    [LocalStorage saveFile:USER_CURRENT data:json];
    return (NSMutableDictionary *)[json JSONValue];
  }
  
  return nil;
}

+ (NSMutableArray *)homeTabs {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/users/current.json" style:nil];
  
  if (json) {
    NSMutableDictionary *dict = [(NSMutableDictionary *)[json JSONValue] objectForKey:@"web_preferences"];
    return (NSMutableArray*)[dict objectForKey:@"home_tabs"];
  }
  return nil;
}

+ (NSMutableDictionary *)pushSettings {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/user_clients/ApplePushDevice.json" style:nil];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
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

+ (NSMutableDictionary *)messages:(NSString *)url olderThan:(NSNumber *)olderThan style:(NSString *)style {
  return [APIGateway messages:url olderThan:olderThan newerThan:nil style:style];
}

+ (NSMutableDictionary *)messages:(NSString *)url newerThan:(NSNumber *)newerThan style:(NSString *)style {
  return [APIGateway messages:url olderThan:nil newerThan:newerThan style:style];
}

+ (NSMutableDictionary *)messages:(NSString *)url olderThan:(NSNumber *)olderThan 
                                                          newerThan:(NSNumber *)newerThan
                                                          style:(NSString *)style {
  
  NSMutableString *params = [NSMutableString stringWithCapacity:10];
  if (olderThan)
    [params appendFormat:@"?older_than=%@", olderThan];
  if (newerThan)
    [params appendFormat:@"?newer_than=%@", newerThan];
  
  BOOL threaded = [LocalStorage threadedMode];
  if (threaded && (newerThan != nil || olderThan != nil))
    [params appendString:@"&threaded=true"];
  else if (threaded)
    [params appendString:@"?threaded=true"];
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"%@.json%@", url, params] style:(NSString *)style];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (BOOL)createMessage:(NSString *)body repliedToId:(NSDecimalNumber *)repliedToId 
                                       groupId:(NSDecimalNumber *)groupId
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
    return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/messages" method:@"POST"];
}

+ (BOOL)followingUser:(NSString *)theUserId {
  return [OAuthGateway httpGet200vsError:[NSString stringWithFormat:@"/api/v1/subscriptions/to_user/%@", theUserId]];
}

+ (BOOL)removeFollow:(NSString *)theUserId {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:theUserId forKey:@"target_id"];
  [params setObject:@"User" forKey:@"target_type"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/subscriptions" method:@"DELETE"];    
}

+ (BOOL)addFollow:(NSString *)theUserId {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:theUserId forKey:@"target_id"];
  [params setObject:@"User" forKey:@"target_type"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/subscriptions" method:@"POST"];  
}

+ (BOOL)sendPushToken:(NSString *)token {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:token forKey:@"user_client[client_id]"];
  [params setObject:@"true" forKey:@"user_client[verified]"];
  [params setObject:@"ApplePushDevice" forKey:@"client_type"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/user_clients" method:@"POST"];  
}

+ (BOOL)updatePushSetting:(NSString *)feed_key status:(NSString *)statusValue {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:statusValue forKey:[NSString stringWithFormat:@"notifications[%@]", feed_key]];
  [params setObject:@"PUT" forKey:@"_method"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/user_clients/ApplePushDevice" method:@"POST"];
  return true;
}

@end
