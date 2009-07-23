//
//  ImageCache.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

static int MAX_FEED_CACHE = 40;


@interface FeedCache : NSObject {

}

+ (NSString *)feedCacheFilePath:(NSString *)url;
+ (NSMutableDictionary *)loadFeed:(NSString *)url;
+ (void)writeFeed:(NSString *)url messages:(NSMutableArray *)messages more:(BOOL)olderAvailable;
+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages more:(BOOL)olderAvailable;

@end
