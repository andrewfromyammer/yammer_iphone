//
//  AutoCompleteCache.h
//  Yammer
//
//  Created by Andrew Arrow on 1/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AutoCompleteCache : NSObject {

}

+ (void)save:(NSString*)prefix data:(NSString*)data;
+ (NSString*)filename:(NSString*)prefix;

@end
