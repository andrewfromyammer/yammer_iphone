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

+ (BOOL)makeHTTPConnection:(NSMutableDictionary *)params path:(NSString *)path method:(NSString *)method {  
  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[OAuthCustom theKey]
                                                  secret:[OAuthCustom secret]];
  
  OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:[LocalStorage getAccessToken]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:accessToken
                                                                    realm:nil   
                                                        signatureProvider:[OAPlaintextSignatureProvider alloc]];
  
  [request setHTTPMethod:method];
  request.HTTPShouldHandleCookies = NO;
  
  NSMutableArray *oauthParams = [NSMutableArray array];
  NSArray *keys = [params allKeys];
  int i=0;
  for (; i<[keys count]; i++) 
    [oauthParams addObject:[[OARequestParameter alloc] initWithName:[keys objectAtIndex:i] 
                                                              value:[params objectForKey:[keys objectAtIndex:i]]]];
  
  [request setParameters:oauthParams];
  [request prepare];
      
  return [OAuthGateway handleConnection:request style:nil] != nil;
}

@end
