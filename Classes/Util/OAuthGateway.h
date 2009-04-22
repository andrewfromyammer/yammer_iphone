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
+ (BOOL)getAccessToken:(NSString *)launchURL;
+ (NSString *)httpGet:(NSString *)path;
+ (NSString *)baseURL;
+ (void)logout;
+ (NSURL *)fixRelativeURL:(NSString *)path;
+ (NSString *)handleConnection:(OAMutableURLRequest *)request;
+ (BOOL)httpGet200vsError:(NSString *)path;

@end
