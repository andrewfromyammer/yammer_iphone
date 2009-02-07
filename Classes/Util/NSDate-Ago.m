//
//  NSData-Ago.m
//  nav
//
//  Created by aa on 7/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSDate-Ago.h"

@implementation NSDate(Ago)

- (NSString *)agoDate {  
  
  double diff = abs([self timeIntervalSinceNow]);
    
  if (diff < 60.0) {
    if (lround(diff) == 0)
      return @"Less than 1 second ago";
    else if (lround(diff) == 1)
      return @"1 second ago";
    else
      return [NSString stringWithFormat:@"%d seconds ago", lround(diff)];
  }
  
  diff = diff / 60.0;
  
  if (diff < 60.0) {
    if (lround(diff) == 1)
      return @"1 minute ago";
    else
      return [NSString stringWithFormat:@"%d minutes ago", lround(diff)];
  }
  
  diff = diff / 60.0;
  
  if (diff < 24.0) {
    if (lround(diff) == 1)
      return @"1 hour ago";
    else
      return [NSString stringWithFormat:@"%d hours ago", lround(diff)];
  }
  
  diff = diff / 24.0;
  
  if (diff < 7.0) {
    if (lround(diff) == 1)
      return @"1 day ago";
    else
      return [NSString stringWithFormat:@"%d days ago", lround(diff)];
  }  
  
  diff = diff / 7.0;
  
  if (lround(diff) == 1)
    return @"1 week ago";
  else
    return [NSString stringWithFormat:@"%d weeks ago", lround(diff)];
}

@end
