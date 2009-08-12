//
//  ImageCache.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "ImageCache.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"

@implementation ImageCache

+ (NSData *)getImageAndSave:(NSString *)url actor_id:(NSString *)actor_id type:(NSString *)type {
  NSData *imageData = [ImageCache getImage:actor_id type:type];
  if (!imageData) {
    [ImageCache saveImage:url actor_id:actor_id type:type];
    return [ImageCache getImage:actor_id type:type];  
  }
  return imageData;
}

+ (NSData *)getImage:(NSString *)actor_id type:(NSString *)type {
  NSString *documentsDirectory = [LocalStorage localPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSString *pic = [NSString stringWithFormat:@"%@/%@_%@", [LocalStorage photoDirectory], actor_id, type];

  if ([fileManager fileExistsAtPath:[documentsDirectory 
                                     stringByAppendingPathComponent:pic]]) {
    NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:[documentsDirectory stringByAppendingPathComponent:pic] traverseLink:YES];
    if ([[ NSDate date] timeIntervalSinceDate: [fileAttributes objectForKey:NSFileModificationDate] ] < 60 * 60 * 24) 
      return [fileManager contentsAtPath:[documentsDirectory stringByAppendingPathComponent:pic]];
  }
  return nil;
}

+ (void)deleteOldestFile:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *list = [fileManager directoryContentsAtPath:path];
  NSMutableDictionary *hash = [NSMutableDictionary dictionary];
  if ([list count] > 500) {
    int i =0;
    for (i=0; i<[list count]; i++) {
      NSString *file = [list objectAtIndex:i];
      
      NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:
                                      [path stringByAppendingPathComponent:file] 
                                                          traverseLink:YES];
      [hash setObject:file forKey:[NSNumber numberWithDouble: [[fileAttributes objectForKey:NSFileModificationDate] timeIntervalSince1970]]];
    }
    NSError *error;
    NSArray *sortedArray = [[hash allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [fileManager removeItemAtPath:[path stringByAppendingPathComponent:[hash objectForKey:[sortedArray objectAtIndex:0]]]
                            error:&error];
  }  
}

+ (void)saveImage:(NSString *)url actor_id:(NSString *)actor_id type:(NSString *)type {
  if (url == nil)
    return;
  
  if ([ImageCache getImage:actor_id type:type] != nil)
    return;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *photoDirectory = [NSString stringWithFormat:@"%@%@", [LocalStorage localPath], [LocalStorage photoDirectory]];
  
  [ImageCache deleteOldestFile:photoDirectory];
  
  NSError *error;
  NSData *data;
  
  @try
  {
    if ([url hasPrefix:@"http"])
      data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:0 error:&error];
    else
      data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OAuthGateway baseURL], url]] options:0 error:&error];
  }
  @catch (NSException *theErr) {
    data = UIImageJPEGRepresentation([UIImage imageNamed:@"no_photo_small.png"], 90);
  }
  [fileManager createFileAtPath:[photoDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", actor_id, type]]
                       contents:data attributes:nil];
}

@end
