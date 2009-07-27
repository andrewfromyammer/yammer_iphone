//
//  OAuthPostMultipart.m
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "OAuthPostMultipart.h"
#import "OAuthCustom.h"
#import "OAuthGateway.h"
#import "LocalStorage.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"

@implementation OAuthPostMultipart

+ (BOOL)makeHTTPConnection:(NSMutableDictionary *)params path:(NSString *)path data:(NSData *)data {  
  
  NSURL *url = [OAuthGateway fixRelativeURL:path];
  
  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY
                                                  secret:OAUTH_SECRET];
  
  OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:[LocalStorage getAccessToken]];
  
  OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                 consumer:consumer
                                                                    token:accessToken
                                                                    realm:nil   
                                                        signatureProvider:nil];
  
  [request setHTTPMethod:@"POST"];
  
  NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
  
	NSMutableData *body = [NSMutableData data];
  // TODO: use params vs "test msg"
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"body\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"test msg"] dataUsingEncoding:NSUTF8StringEncoding]];
	
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"attachment1\"; filename=\"iphonefile.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:data]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];  
  
  [request prepare];
  
	[request setHTTPBody:body];
  [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"]; 
  
  return [OAuthGateway handleConnection:request] != nil;
}

@end
