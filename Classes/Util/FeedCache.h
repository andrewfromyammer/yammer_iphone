//
//  ImageCache.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FeedCache : NSObject {

}

+ (NSString *)feedCacheFilePath:(NSString *)url;
+ (NSMutableArray *)loadFeed:(NSString *)url;
+ (void)writeFeed:(NSString *)url messages:(NSMutableArray *)messages;
+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages;

@end
