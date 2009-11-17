//
//  LocalStorage.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedDictionary.h"

#define USER_CURRENT    @"/account/user_current.json"
#define DIRECTORY_CACHE @"/account/directory_cache.json"
#define SETTINGS        @"/account/settngs.json"
#define MESSAGE_CACHE   @"message_cache_v3.sqlite"

#define ATTACHMENTS             @"/attachments"
#define ATTACHMENT_THUMBNAILS   @"/attachment_thumbnails"

#define TOKENS    @"/account/tokens.json"

@interface LocalStorage : NSObject {

}

+ (NSString *)localPath;

+ (NSString *)getRequestToken;
+ (NSString *)getAccessToken;
+ (void)saveFile:(NSString *)name data:(NSString *)data;
+ (NSString *)getFile:(NSString *)name;
+ (void)removeFile:(NSString *)name;
+ (NSDate *)getFileDate:(NSString *)name;

+ (void)saveRequestToken:(NSString *)token;
+ (void)saveAccessToken:(NSString *)token;
+ (void)removeRequestToken;
+ (void)removeAccessToken;

+ (NSString *)getBaseURL;
+ (void)saveBaseURL:(NSString *)string;
+ (void)removeBaseURL;
+ (void)deleteAccountInfo;

+ (NSString *)photoDirectory;
+ (NSString *)feedDirectory;
+ (void)saveFeedInfo:(NSMutableDictionary *)feed;
+ (FeedDictionary *)getFeedInfo;

+ (void)saveDraft:(NSString *)draft;
+ (NSString *)getDraft;

+ (FeedDictionary *)getReceivedInfo;

+ (BOOL)threading;
+ (BOOL)threadingFromDisk;
+ (NSString *)getNameField;
+ (NSString*)fontSize;
+ (NSString*)fontSizeFromDisk;
+ (void)saveSetting:(NSString*)key value:(NSString*)value;

@end
