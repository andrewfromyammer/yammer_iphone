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

+ (NSMutableArray *)loadFeed:(NSString *)url {
  NSString *path = [FeedCache feedCacheFilePath:url];  
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath:path]) {
    return (NSMutableArray*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                               encoding:NSUTF8StringEncoding] JSONValue];
  }
  return nil;
}

+ (void)writeFeed:(NSString *)url messages:(NSMutableArray *)messages {
  
  if ([messages count] == 0)
    return;
  
  NSString *path = [FeedCache feedCacheFilePath:url];    
  NSFileManager *fileManager = [NSFileManager defaultManager];  
  if ([fileManager fileExistsAtPath:path]) {
    NSMutableArray *existing = (NSMutableArray*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                                                       encoding:NSUTF8StringEncoding] JSONValue];
    
    NSMutableDictionary *lastNew       = [messages lastObject];
    NSMutableDictionary *firstNew      = [messages objectAtIndex:0];
    NSMutableDictionary *firstExisting = [existing objectAtIndex:0];
    NSMutableDictionary *lastExisting  = [existing lastObject];    

    if ([[lastNew objectForKey:@"id"] intValue] > [[firstExisting objectForKey:@"id"] intValue]) {
      [messages addObjectsFromArray:existing];
      [FeedCache trimArrayAndWrite:path messages:messages];
    }
    else if ([[lastExisting objectForKey:@"id"] intValue] > [[firstNew objectForKey:@"id"] intValue]) {
      [existing addObjectsFromArray:messages];
      [FeedCache trimArrayAndWrite:path messages:existing];
    }
  } else
    [FeedCache trimArrayAndWrite:path messages:messages];
}

+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages {  
  NSFileManager *fileManager = [NSFileManager defaultManager];  

  NSRange range;
  range.location = MAX_FEED_CACHE;
  range.length = [messages count] - MAX_FEED_CACHE;
  if ([messages count] > MAX_FEED_CACHE)
    [messages removeObjectsInRange:range];
  [fileManager createFileAtPath:path contents:[[messages JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}


@end
