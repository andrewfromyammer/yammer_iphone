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
  NSString *path = [FeedCache feedCacheFilePath:url];  
  
  NSFileManager *fileManager = [NSFileManager defaultManager];  
  if ([fileManager fileExistsAtPath:path]) {
    NSMutableArray *existing = (NSMutableArray*)[[[NSString alloc] initWithData:[fileManager contentsAtPath:path] 
                                                                       encoding:NSUTF8StringEncoding] JSONValue];
    NSMutableDictionary *lastNew       = [messages lastObject];
    NSMutableDictionary *firstExisting = [existing objectAtIndex:0];
    
    if ([lastNew objectForKey:@"id"] > [firstExisting objectForKey:@"id"]) {
      [messages addObjectsFromArray:existing];
      [FeedCache trimArrayAndWrite:path messages:messages];
    }
    else {
      [existing addObjectsFromArray:messages];
      [FeedCache trimArrayAndWrite:path messages:existing];
    }
  } else
    [FeedCache trimArrayAndWrite:path messages:messages];
}

+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages {  
  NSFileManager *fileManager = [NSFileManager defaultManager];  

  NSRange range;
  range.location = 200;
  range.length = [messages count] - 200;
  if ([messages count] > 200)
    [messages removeObjectsInRange:range];
  [fileManager createFileAtPath:path contents:[[messages JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}


@end
