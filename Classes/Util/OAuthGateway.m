//
//  OAuthGateway.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "OAuthCustom.h"
#import "OAuthGateway.h"
#import "LocalStorage.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "YammerAppDelegate.h"

static NSString *ERROR_OUT_OF_RANGE = @"Network out of range.";

@implementation OAuthGateway

+ (NSString *)baseURL {
  return @"http://192.168.1.151:3000";   
//  return @"https://staging.yammer.com";
  
  NSString *url = [LocalStorage getBaseURL];
  if (url)
    return url;

  //return @"http://aa.com:3000";  
  //return @"https://www.yammer.com";  
}

+ (void)logout {
  [LocalStorage deleteAccountInfo];
  exit(0); 
}


+ (void)getRequestToken:(BOOL)createNewAccount {
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY
                                                  secret:OAUTH_SECRET];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", [OAuthGateway baseURL]]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:nil   // we don't have a Token yet
                                                                    realm:nil   // our service provider doesn't specify a realm
                                                        signatureProvider:nil]; // use the default method, HMAC-SHA1
  
  [request setHTTPMethod:@"POST"];
  [request prepare];
  
  NSURLResponse *response;
  NSError *error;
  NSData *responseData;
  NSString *login = @"true";
  if (createNewAccount)
    login = @"false";
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if (response == nil || responseData == nil || error != nil || [(NSHTTPURLResponse *)response statusCode] >= 400) {
    [YammerAppDelegate showError:@"oauth getRequestToken"];
  } else {
    NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];

    OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [LocalStorage saveRequestToken:responseBody];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                [NSString stringWithFormat:@"%@/oauth/authorize?oauth_token=%@&login=%@", 
                                                 [OAuthGateway baseURL], 
                                                 requestToken.key,
                                                 login
                                                 ]]];        
  }
}

+ (BOOL)getAccessToken:(NSString *)launchURL {

  OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:[LocalStorage getRequestToken]];  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY
                                                  secret:OAUTH_SECRET];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/access_token", [OAuthGateway baseURL]]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:requestToken
                                                                    realm:nil   
                                                        signatureProvider:nil];
  
  [request setHTTPMethod:@"POST"];
  request.HTTPShouldHandleCookies = NO;
  
  // yammer://verify?oauth_token=1111111111111&callback_token=AC45&more=true

  NSRange range = [launchURL rangeOfString:@"?"];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (range.location != NSNotFound) {
    NSArray *parts = [[launchURL substringFromIndex:range.location+1] componentsSeparatedByString:@"&"];
    int i=0;
    for (i=0; i<[parts count]; i++) {
      NSArray *key_value = [[parts objectAtIndex:i] componentsSeparatedByString:@"="];
      if ([key_value count] == 2)
        [dict setObject:[key_value objectAtIndex:1] forKey:[key_value objectAtIndex:0]];
    }
  }

  NSMutableArray *oauthParams = [NSMutableArray array];
  [oauthParams addObject:[[OARequestParameter alloc] initWithName:@"callback_token" 
                                                            value:[dict objectForKey:@"callback_token"]]];
	
  [request setParameters:oauthParams];  	
  [request prepare];
	
  
  NSURLResponse *response;
  NSError *error;
  NSData *responseData;
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if (response == nil || responseData == nil || error != nil || [(NSHTTPURLResponse *)response statusCode] >= 400) {
    return false;
  } else {
    NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
    
    [LocalStorage saveAccessToken:responseBody];
    return true;
  }  
  
}

+ (NSURL *)fixRelativeURL:(NSString *)path {
  if (![path hasPrefix:@"http"])
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OAuthGateway baseURL], path]];
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@", path]];
}

+ (NSString *)handleConnection:(OAMutableURLRequest *)request {
  NSHTTPURLResponse *response;
  NSError *error;
  NSData *responseData;
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if ((response == nil || responseData == nil) && error == nil) {
    [YammerAppDelegate showError:ERROR_OUT_OF_RANGE];
    return nil;
  } else if (error != nil) {
    if ([error code] == -1012) {
      [LocalStorage deleteAccountInfo];
      exit(1);
    }
    else
      [YammerAppDelegate showError:ERROR_OUT_OF_RANGE];
    return nil;
  } else if ([response statusCode] >= 400) {
    NSString *detail = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(detail);
    if ([detail length] > 30)
      detail = [detail substringToIndex:30];
    [YammerAppDelegate showError:[NSString stringWithFormat:@"%d %@", [response statusCode], detail]];
    return nil;
  }
  
  return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

+ (NSString *)httpGet:(NSString *)path {  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
    
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY
                                                  secret:OAUTH_SECRET];
  
  OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:[LocalStorage getAccessToken]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:accessToken
                                                                    realm:nil   
                                                        signatureProvider:nil];
  
  request.HTTPShouldHandleCookies = NO;
  
  [request prepare];
  return [OAuthGateway handleConnection:request];  
}

+ (BOOL)httpGet200vsError:(NSString *)path {  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY
                                                  secret:OAUTH_SECRET];
  
  OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:[LocalStorage getAccessToken]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:accessToken
                                                                    realm:nil   
                                                        signatureProvider:nil];
  
  request.HTTPShouldHandleCookies = NO;
  
  [request prepare];
  
  NSHTTPURLResponse *response;
  NSError *error;
  NSData *responseData;
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if ((response == nil || responseData == nil) && error == nil) {
    return false;
  } else if (error != nil) {
    return false;
  } else if ([response statusCode] >= 400) {
    return false;
  }
  return true;
}

@end
