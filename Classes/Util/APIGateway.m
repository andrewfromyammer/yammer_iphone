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

@implementation APIGateway

+ (NSMutableDictionary *)usersCurrent {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/users/current.json"];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (NSMutableArray *)homeTabs {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/users/current.json"];
  
  if (json) {
    NSMutableDictionary *dict = [(NSMutableDictionary *)[json JSONValue] objectForKey:@"web_preferences"];
    return (NSMutableArray*)[dict objectForKey:@"home_tabs"];
  }
  return nil;
}

+ (NSMutableDictionary *)pushSettings {
  
  NSString *json = [OAuthGateway httpGet:@"/api/v1/user_clients/ApplePushDevice.json"];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (NSMutableArray *)users:(int)page {

  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/users.json?page=%d", page]];
  
  if (json)
    return (NSMutableArray *)[json JSONValue];
  
  return nil;
}

+ (NSMutableDictionary *)userById:(NSString *)theUserId {
  
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"/api/v1/users/%@.json", theUserId]];
    
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (NSMutableDictionary *)messages:(NSString *)url olderThan:(NSDecimalNumber *)messageId {
  NSString *older = @"";
  if (messageId)
    older = [NSString stringWithFormat:@"?older_than=%@", messageId];
  NSString *json = [OAuthGateway httpGet:[NSString stringWithFormat:@"%@.json%@", url, older]];
  
  if (json)
    return (NSMutableDictionary *)[json JSONValue];
  
  return nil;
}

+ (BOOL)createMessage:(NSString *)body repliedToId:(NSDecimalNumber *)repliedToId groupId:(NSDecimalNumber *)groupId {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setObject:body forKey:@"body"];
  if (repliedToId)
    [params setObject:[repliedToId description] forKey:@"replied_to_id"];
  if (groupId)
    [params setObject:[groupId description] forKey:@"group_id"];
  
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
  [params setObject:@"client_type" forKey:@"ApplePushDevice"];
  
  return [OAuthPostURLEncoded makeHTTPConnection:params path:@"/api/v1/user_clients" method:@"POST"];  
}

@end
