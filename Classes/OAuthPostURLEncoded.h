//
//  OAuthPostURLEncoded.h
//  Yammer
//
//  Created by aa on 2/1/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OAuthPostURLEncoded : NSObject {

}

+ (NSString*)makeHTTPConnection:(NSMutableDictionary *)params 
													 path:(NSString *)path 
												 method:(NSString *)method 
											addHeader:(BOOL)addHeader
													style:(NSString*)style;

@end
