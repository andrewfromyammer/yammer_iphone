//
//  OAuthPostURLEncoded.m
//  Yammer
//
//  Created by aa on 2/1/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "OAuthPostURLEncoded.h"
#import "OAuthCustom.h"
#import "OAuthGateway.h"
#import "LocalStorage.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAPlaintextSignatureProvider.h"

@implementation OAuthPostURLEncoded

+ (BOOL)makeHTTPConnection:(NSMutableDictionary *)params path:(NSString *)path method:(NSString *)method style:(NSString*)style {  
  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [OAuthGateway addAccessAuthHeader:request];
  [request setHTTPMethod:method];
  request.HTTPShouldHandleCookies = NO;
  
  NSMutableArray *oauthParams = [NSMutableArray array];
  NSArray *keys = [params allKeys];
  int i=0;
  for (; i<[keys count]; i++) 
    [oauthParams addObject:[[OARequestParameter alloc] initWithName:[keys objectAtIndex:i] 
                                                              value:[params objectForKey:[keys objectAtIndex:i]]]];
  
  [request setParameters:oauthParams];
      
  return [OAuthGateway handleConnection:request style:style] != nil;
}

@end
