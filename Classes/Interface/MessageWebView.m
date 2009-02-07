//
//  MessageWebView.m
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "MessageWebView.h"
#import "OAuthGateway.h"

@implementation MessageWebView

- (id)init {
  [super initWithFrame:CGRectMake(0, 48, 320, 325)];
  self.delegate = self;  
  return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if ([[request.URL absoluteString] isEqualToString:@"file://message"])
    return true;
  
  [[UIApplication sharedApplication] openURL:request.URL];
  return false;
}

/* should be changed to a good regex for finding URLs vs. the logic below.
  Known problems: https links are not found
 possible regex: /((http(s?))\:\/\/)([0-9a-zA-Z\-]+\.)+[a-zA-Z]{2,6}(\:[0-9]+)?(\/([\w#!:.?+=&%@~*\';,\-\/\$])*)?/g;
 or  /((?:http(?:s?)\:\/\/|www\.[^\.])\S+[A-z0-9\/])/g;
 */
- (void)setHTML:(NSMutableDictionary *)message {
  NSMutableDictionary *body = [message objectForKey:@"body"];
  NSString *plain = [body objectForKey:@"plain"];
  
  NSMutableArray *startPoints = [NSMutableArray array];
  NSMutableArray *urlLengths = [NSMutableArray array];
  
  NSRange r1;
  r1.location = 0;
  r1.length = [plain length];  
  while (true) {
    NSRange r2 = [plain rangeOfString:@"http://" options:(NSCaseInsensitiveSearch) range:r1];
    NSRange r3 = [plain rangeOfString:@"www." options:(NSCaseInsensitiveSearch) range:r1];
    
    if (r2.length == 0 && r3.length > 0)
      r2 = r3;
    else if (r2.location > r3.location && r3.length > 0)
      r2 = r3;
    
    
    if (r2.length > 0) {
      int i=r2.location;
      for (; i< [plain length]; i++) {
        char c = [plain characterAtIndex:i];
        if (c == ' ')
          break;
      }
      
      NSRange urlRange;
      urlRange.location = r2.location;
      urlRange.length = i - r2.location;  
      
      [startPoints addObject:[NSNumber numberWithInt:r2.location]];
      [urlLengths addObject:[NSNumber numberWithInt:i - r2.location]];
      
      r1.location = i+1;
      r1.length = [plain length] - r1.location;
    } else
      break;
  }
  
  NSRange preRange;
  preRange.location = 0;
  
  NSMutableString *buff = [NSMutableString string];
  int i=0;
  for (i=0; i<[startPoints count]; i++) {
    int start = [[startPoints objectAtIndex:i] intValue];
    int len = [[urlLengths objectAtIndex:i] intValue];
    
    preRange.length = start - preRange.location;
    
    NSRange urlRange;
    urlRange.location = start;
    urlRange.length = len;
    
    [buff appendString:[plain substringWithRange:preRange]];
    NSString *url = [plain substringWithRange:urlRange];
    if (![url hasPrefix:@"http"])
      url = [NSString stringWithFormat:@"http://%@", url];
    [buff appendFormat:@"<a href=\"%@\">%@</a>", url, url];
    
    preRange.location = start + len;
  }
  
  preRange.length = [plain length] - preRange.location;
  [buff appendString:[plain substringWithRange:preRange]];  
  
  NSMutableArray *attachments = [message objectForKey:@"attachments"];
  for (i=0; i<[attachments count]; i++) {
    NSMutableDictionary *attachment = [attachments objectAtIndex:i];
    [buff appendString:@"<p>"];
    [buff appendString:@"<img src=\""];
    [buff appendString:[OAuthGateway baseURL]];
    [buff appendString:@"/images/paperclip.gif\"> <a href=\""];
    [buff appendString:[attachment objectForKey:@"web_url"]];
    [buff appendString:@"\">"];
    [buff appendString:[attachment objectForKey:@"name"]];
    [buff appendString:@"</a></p>"];
  }  
  
  [self loadHTMLString:[NSString stringWithFormat:@"<html><body style=\"font-size: 16px; font-family: arial;\">%@</body></html>", 
                       buff] 
               baseURL:[NSURL URLWithString:@"file://message"]];  
}

@end
