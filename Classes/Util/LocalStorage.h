//
//  LocalStorage.h
//  Yammer
//
//  Created by aa on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorage : NSObject {

}

+ (NSString *)localPath;

+ (NSString *)getRequestToken;
+ (NSString *)getAccessToken;
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
