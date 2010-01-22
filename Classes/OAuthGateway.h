//
//  OAuthGateway.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAMutableURLRequest.h"

@interface OAuthGateway : NSObject {

}

+ (void)getRequestToken:(BOOL)createNewAccount;
+ (BOOL)getAccessToken:(NSString *)launchURL callbackToken:(NSString *)token;
+ (void)addAuthHeader:(NSMutableURLRequest*)request;

+ (NSString *)httpGet:(NSString *)path style:(NSString *)style;
+ (NSString *)baseURL;
+ (void)logout;
+ (NSURL *)fixRelativeURL:(NSString *)path;
+ (NSString *)handleConnection:(NSMutableURLRequest *)request style:(NSString *)style;
+ (BOOL)httpGet200vsError:(NSString *)path;
+ (NSData *)httpDataGet:(NSString *)path;

@end
