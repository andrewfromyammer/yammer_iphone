//
//  OAuthPostMultipart.h
//  Yammer
//
//  Created by aa on 2/2/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OAuthPostMultipart : NSObject {

}

+ (BOOL)makeHTTPConnection:(NSMutableDictionary *)params path:(NSString *)path data:(NSData *)data;

@end
