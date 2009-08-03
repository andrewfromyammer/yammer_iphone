//
//  LocalStorage.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USER_CURRENT @"/account/user_current.json"

@interface LocalStorage : NSObject {

}

+ (NSString *)localPath;

+ (NSString *)getRequestToken;
+ (NSString *)getAccessToken;
+ (void)saveFile:(NSString *)name data:(NSString *)data;
+ (NSString *)getFile:(NSString *)name;
+ (void)removeFile:(NSString *)name;

+ (void)saveRequestToken:(NSString *)token;
+ (void)saveAccessToken:(NSString *)token;
+ (void)removeRequestToken;

+ (NSString *)getBaseURL;
+ (void)saveBaseURL:(NSString *)string;
+ (void)removeBaseURL;
+ (void)deleteAccountInfo;

+ (NSString *)photoDirectory;
+ (NSString *)feedDirectory;
+ (void)saveFeedInfo:(NSMutableDictionary *)feed;
+ (NSMutableDictionary *)getFeedInfo;

+ (void)saveDraft:(NSString *)draft;
+ (NSString *)getDraft;

@end
