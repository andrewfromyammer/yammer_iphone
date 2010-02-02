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
#import "OAuthPostURLEncoded.h"
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
	
  NSString *oauthHeader = [NSString stringWithFormat:@"OAuth realm=\"\", oauth_consumer_key=\"%@\", %@oauth_signature_method=\"PLAINTEXT\", oauth_signature=\"%@\", oauth_timestamp=\"%f\", oauth_nonce=\"%f\", %@oauth_version=\"1.0\"",
                             [OAuthCustom theKey],
                             oauthToken,
                             sig,
                             [[NSDate date] timeIntervalSince1970],
   													 [[NSDate date] timeIntervalSince1970],
   													 oauthVerifier];	
	
  [request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
}

+ (NSString*)getWrapToken:(NSString*)email password:(NSString*)password {
  
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:email forKey:@"wrap_username"];
	[params setObject:password forKey:@"wrap_password"];
	[params setObject:[OAuthCustom theKey] forKey:@"wrap_client_id"];
	

	return [OAuthPostURLEncoded 
										makeHTTPConnection:params 
										path:@"/oauth_wrap/access_token" 
										method:@"POST" 
										addHeader:NO
										style:@"silent"];  
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
	
	if (style != nil)
		[request setTimeoutInterval:10.0];
  
  responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  yammer.lastStatusCode = [response statusCode];
	
  if ((response == nil || responseData == nil) && error == nil) {
    [YammerAppDelegate showError:ERROR_OUT_OF_RANGE style:style];
    return nil;
  } else if (error != nil) {
	  [YammerAppDelegate showError:ERROR_OUT_OF_RANGE style:style];
		if ([error code] == NSURLErrorUserCancelledAuthentication)
  		yammer.lastStatusCode = 401;
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
  
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [OAuthGateway addAccessAuthHeader:request];
  request.HTTPShouldHandleCookies = NO;
  
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
  
  NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
  [OAuthGateway addAccessAuthHeader:request];
  request.HTTPShouldHandleCookies = NO;
  
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
