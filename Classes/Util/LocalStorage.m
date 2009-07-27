//
//  LocalStorage.m
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocalStorage.h"
#import "OAuthGateway.h"

static NSString *ACCOUNT_DIR   = @"/account";
static NSString *PHOTO_DIR     = @"/photos";
static NSString *FEED_DIR      = @"/feeds";
static NSString *DRAFT         = @"/account/draft.txt";
static NSString *REQUEST_TOKEN = @"/account/request_token.txt";
static NSString *ACCESS_TOKEN  = @"/account/access_token.txt";
static NSString *USERFILE      = @"/account/user.txt";
static NSString *PASSFILE      = @"/account/pass.txt";
static NSString *FEEDFILE_OLD  = @"/account/feed.txt";
static NSString *FEEDFILE      = @"/account/feed2.txt";
static NSString *CURRENTFILE   = @"/account/current.txt";
static NSString *BASE_URL      = @"/account/base_url.txt";

@implementation LocalStorage

+ (NSString *)photoDirectory {
  return PHOTO_DIR;
}

+ (NSString *)feedDirectory {
  return FEED_DIR;
}

+ (NSString *)localPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

+ (void)createDirectories {
  NSString *documentsDirectory = [LocalStorage localPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  [fileManager createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:ACCOUNT_DIR] attributes:nil];
  [fileManager createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:PHOTO_DIR] attributes:nil];
  [fileManager createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:FEED_DIR] attributes:nil];
  
  NSError *error;
  [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:USERFILE] error:&error];  
  [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:PASSFILE] error:&error];  
  [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:FEEDFILE_OLD] error:&error];  
  [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:CURRENTFILE] error:&error];  
}

+ (NSString *)getFile:(NSString *)name {  
  NSString *documentsDirectory = [LocalStorage localPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if (![fileManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:name]])
    return nil;
  
  return [[NSString alloc] initWithData:[fileManager contentsAtPath:
                                         [documentsDirectory stringByAppendingPathComponent:name]]
                               encoding:NSUTF8StringEncoding];
}

+ (void)saveFile:(NSString *)name data:(NSString *)data {
  NSString *documentsDirectory = [LocalStorage localPath];  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  [fileManager createFileAtPath:[documentsDirectory stringByAppendingPathComponent:name]
                       contents:[data dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+ (void)removeFile:(NSString *)name {
  NSError *error;
  NSString *documentsDirectory = [LocalStorage localPath];  
  NSFileManager *fileManager = [NSFileManager defaultManager];  
  [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:name] error:&error];    
}

+ (NSString *)getAccessToken {
  [LocalStorage createDirectories];
  return [LocalStorage getFile:ACCESS_TOKEN];
}

+ (NSString *)getRequestToken {
  return [LocalStorage getFile:REQUEST_TOKEN];
}

+ (NSString *)getDraft {
  return [LocalStorage getFile:DRAFT];
}

+ (void)saveRequestToken:(NSString *)token {
  [LocalStorage saveFile:REQUEST_TOKEN data:token];
}

+ (void)saveDraft:(NSString *)draft {
  [LocalStorage saveFile:DRAFT data:draft];
}

+ (void)removeRequestToken {
  [LocalStorage removeFile:REQUEST_TOKEN];
}

+ (void)saveAccessToken:(NSString *)token {
  [LocalStorage saveFile:ACCESS_TOKEN data:token];
  [LocalStorage removeRequestToken];
}

+ (NSString *)getBaseURL {
  return [LocalStorage getFile:BASE_URL];
}

+ (void)saveBaseURL:(NSString *)string {
  [LocalStorage saveFile:BASE_URL data:string];
}

+ (void)removeBaseURL {
  [LocalStorage removeFile:BASE_URL];
}

+ (void)deleteAccountInfo {
  [LocalStorage removeFile:ACCESS_TOKEN];
  [LocalStorage removeFile:REQUEST_TOKEN];
  [LocalStorage removeFile:DRAFT];  
  [LocalStorage removeFile:FEEDFILE];
  [LocalStorage removeFile:FEED_DIR];
}

+ (void)saveFeedInfo:(NSMutableDictionary *)feed {
  [LocalStorage saveFile:FEEDFILE data:[NSString stringWithFormat:@"%@\n%@\n%@\n%@", [feed objectForKey:@"name"], 
                                        [feed objectForKey:@"type"],
                                        [feed objectForKey:@"url"],
                                        [feed objectForKey:@"group_id"]
                                        ]];
}

+ (NSMutableDictionary *)getFeedInfo {
  
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  [dic setObject:@"My Feed" forKey:@"name"];
  [dic setObject:@"following" forKey:@"type"];
  [dic setObject:@"/api/v1/messages/following" forKey:@"url"];
  [dic setObject:@"(null)" forKey:@"group_id"];
  
  NSString *file = [LocalStorage getFile:FEEDFILE];
  
  if (!file)
    return dic;
    
  NSArray *array = [file componentsSeparatedByString:@"\n"];
  dic = [NSMutableDictionary dictionary];
  [dic setObject:[array objectAtIndex:0] forKey:@"name"];
  [dic setObject:[array objectAtIndex:1] forKey:@"type"];
  [dic setObject:[array objectAtIndex:2] forKey:@"url"];
  [dic setObject:[array objectAtIndex:3] forKey:@"group_id"];
  
  return dic;
}


@end
