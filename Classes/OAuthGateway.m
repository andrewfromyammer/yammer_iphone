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
  NSString *url = [LocalStorage getBaseURL];
  if (url)
    return url;

  return [OAuthCustom baseURL];
}

+ (void)logout {
  [LocalStorage deleteAccountInfo];
  exit(0); 
}

+ (NSString*)extractToken:(NSString*)body {
	NSArray *pairs = [body componentsSeparatedByString:@"&"];
	return [[[pairs objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
}

+ (NSString*)extractSecret:(NSString*)body {
	NSArray *pairs = [body componentsSeparatedByString:@"&"];
	return [[[pairs objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
}

+ (void)addAccessAuthHeader:(NSMutableURLRequest*)request {
	NSString* token = [OAuthGateway extractToken:[LocalStorage getAccessToken]];
	NSString* secret = [OAuthGateway extractSecret:[LocalStorage getAccessToken]];	
	[OAuthGateway addAuthHeader:request token:token secret:secret verifier:nil];
}

+ (void)addAuthHeader:(NSMutableURLRequest*)request token:(NSString*)token secret:(NSString*)secret verifier:(NSString*)verifier {	
	NSString* oauthToken = @"";
	NSString* oauthVerifier = @"";
  NSString* sig = [NSString stringWithFormat:@"%@%@26", [OAuthCustom secret], CFSTR("%")];
	
	if (token) {
		oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", token];		
		sig = [NSString stringWithFormat:@"%@%@", sig, secret];
	}
	
	if (verifier) {
		oauthVerifier = [NSString stringWithFormat:@"oauth_verifier=\"%@\", ", verifier];
	}
	
  NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"PLAINTEXT\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", %@oauth_version=\"1.0\"",
                             [OAuthCustom theKey],
                             oauthToken,
                             sig,
                             [[NSDate date] description],
														 [[NSDate date] description],
   													 oauthVerifier];
	
	NSLog(oauthHeader);
	
  [request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

+ (void)getRequestToken:(BOOL)createNewAccount {
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", [OAuthGateway baseURL]]];
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
	[OAuthGateway addAuthHeader:request token:nil secret:nil verifier:nil];	
	  
  [request setHTTPMethod:@"POST"];
  
  NSURLResponse *response;
  NSError *error;
  NSData *responseData;
  NSString *login = @"true";
  if (createNewAccount)
    login = @"false";
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if (response == nil || responseData == nil || error != nil || [(NSHTTPURLResponse *)response statusCode] >= 400) {
    [YammerAppDelegate showError:@"oauth getRequestToken" style:nil];
  } else {
    NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];

    [LocalStorage saveRequestToken:responseBody];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                [NSString stringWithFormat:@"%@/oauth/authorize?oauth_token=%@&login=%@", 
                                                 [OAuthGateway baseURL], 
																								 [OAuthGateway extractToken:responseBody],
                                                 login
                                                 ]]];
  }
}

+ (BOOL)getAccessToken:(NSString *)launchURL callbackToken:(NSString *)callbackToken {  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/access_token", [OAuthGateway baseURL]]];
  
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];

	NSString* token = [OAuthGateway extractToken:[LocalStorage getRequestToken]];
	NSString* secret = [OAuthGateway extractSecret:[LocalStorage getRequestToken]];	
  
  [request setHTTPMethod:@"POST"];
  request.HTTPShouldHandleCookies = NO;
  
  NSString* verifier = @"";
  if (launchURL) {
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
    
    verifier = [dict objectForKey:@"callback_token"];
  } else if (callbackToken) {
    verifier = callbackToken;
  }  

	[OAuthGateway addAuthHeader:request token:token secret:secret verifier:verifier];
	
  NSURLResponse *response;
  NSError *error;
  NSData *responseData;
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if (response == nil || responseData == nil || error != nil || [(NSHTTPURLResponse *)response statusCode] >= 400)
    return false;
  else {
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

+ (NSString *)handleConnection:(NSMutableURLRequest*)request style:(NSString*)style {  
  NSHTTPURLResponse *response;
  NSError *error;
  NSData *responseData;
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

  if ((response == nil || responseData == nil) && error == nil) {
    [YammerAppDelegate showError:ERROR_OUT_OF_RANGE style:style];
    return nil;
  } else if (error != nil) {
    if ([error code] == -1012) {
      [LocalStorage deleteAccountInfo];
      exit(1);
    }
    else
      [YammerAppDelegate showError:ERROR_OUT_OF_RANGE style:style];
    return nil;
  } else if ([response statusCode] >= 400) {
  
//    NSString *detail = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(detail);
    [YammerAppDelegate showError:[NSString stringWithFormat:@"We're sorry, something has gone wrong and we've been notified.  Error code: %d", [response statusCode]] style:style];
    return nil;
  }
  
  return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

+ (NSString *)httpGet:(NSString *)path style:(NSString *)style {  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
    
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [OAuthGateway addAccessAuthHeader:request];
  request.HTTPShouldHandleCookies = NO;
  
  return [OAuthGateway handleConnection:request style:style];  
}

+ (BOOL)httpGet200vsError:(NSString *)path {  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[OAuthCustom theKey]
                                                  secret:[OAuthCustom secret]];
  
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

+ (NSData *)httpDataGet:(NSString *)path {  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[OAuthCustom theKey]
                                                  secret:[OAuthCustom secret]];
  
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
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

  if ((response == nil || responseData == nil) && error == nil) {
    return nil;
  } else if (error != nil) {
    return nil;
  } else if ([response statusCode] >= 400) {
    return nil;
  }
  
  return responseData;
}

@end
