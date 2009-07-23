//
//  ImageCache.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedCache.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"

@implementation FeedCache

+ (NSString *)feedCacheFilePath:(NSString *)url {
  NSString *file;
  
  if (![url hasPrefix:@"http"])
    file = [NSString stringWithFormat:@"%@%@", [OAuthGateway baseURL], url];
  else
    file = [NSString stringWithFormat:@"%@", url];
  
  file = [file stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
  file = [file stringByReplacingOccurrencesOfString:@":" withString:@"_"];
  file = [file stringByReplacingOccurrencesOfString:@"." withString:@"_"];
  
  return [[LocalStorage localPath] stringByAppendingPathComponent: 
          [NSString stringWithFormat:@"%@/%@", [LocalStorage feedDirectory], file]];  
}

+ (NSMutableDictionary *)loadFeed:(NSString *)url {
  NSString *path = [FeedCache feedCacheFilePath:url];  
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath:path]) {
    return (NSMutableDictionary*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                               encoding:NSUTF8StringEncoding] JSONValue];
  }
  return nil;
}

+ (void)writeFeed:(NSString *)url messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {
  
  if ([messages count] == 0)
    return;
  
  NSString *path = [FeedCache feedCacheFilePath:url];    
  NSFileManager *fileManager = [NSFileManager defaultManager];  
  if ([fileManager fileExistsAtPath:path]) {
    NSMutableDictionary *dict = (NSMutableDictionary*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                                                       encoding:NSUTF8StringEncoding] JSONValue];
    NSMutableArray *existing = [dict objectForKey:@"messages"];
    BOOL existingOlderAvailable = [[[dict objectForKey:@"meta"] objectForKey:@"olderAvailable"] isEqualToString:@"t"];    
    
    NSMutableDictionary *lastNew       = [messages lastObject];
    NSMutableDictionary *firstNew      = [messages objectAtIndex:0];
    NSMutableDictionary *firstExisting = [existing objectAtIndex:0];
    NSMutableDictionary *lastExisting  = [existing lastObject];    

    if ([[lastNew objectForKey:@"id"] intValue] > [[firstExisting objectForKey:@"id"] intValue]) {
      [messages addObjectsFromArray:existing];
      [FeedCache trimArrayAndWrite:path messages:messages more:existingOlderAvailable];
    }
    else if ([[lastExisting objectForKey:@"id"] intValue] > [[firstNew objectForKey:@"id"] intValue]) {
      [existing addObjectsFromArray:messages];
      [FeedCache trimArrayAndWrite:path messages:existing more:olderAvailable];
    }
  } else
    [FeedCache trimArrayAndWrite:path messages:messages more:olderAvailable];
}

+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages more:(BOOL)olderAvailable {  
  NSFileManager *fileManager = [NSFileManager defaultManager];  

  NSRange range;
  range.location = MAX_FEED_CACHE;
  range.length = [messages count] - MAX_FEED_CACHE;
  if ([messages count] > MAX_FEED_CACHE) {
    olderAvailable = true;
    [messages removeObjectsInRange:range];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:messages forKey:@"messages"];
  NSMutableDictionary *meta = [NSMutableDictionary dictionary];
  if (olderAvailable)
    [meta setObject:@"t" forKey:@"olderAvailable"];
  else
    [meta setObject:@"f" forKey:@"olderAvailable"];
  [dict setObject:meta forKey:@"meta"];
  [fileManager createFileAtPath:path contents:[[dict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}


@end
