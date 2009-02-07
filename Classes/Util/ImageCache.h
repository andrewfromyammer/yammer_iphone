//
//  ImageCache.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {

}

+ (NSData *)getImageAndSave:(NSString *)url user_id:(NSString *)user_id type:(NSString *)type;
+ (NSData *)getImage:(NSString *)user_id type:(NSString *)type;
+ (void)saveImage:(NSString *)url user_id:(NSString *)user_id type:(NSString *)type;
  
@end
