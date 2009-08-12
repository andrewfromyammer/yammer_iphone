//
//  ImageCache.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

static int MAX_FEED_CACHE = 100;


@interface FeedCache : NSObject {

}

+ (NSString *)feedCacheFilePath:(NSString *)url;
+ (NSMutableDictionary *)loadFeed:(NSString *)url;

+ (BOOL)writeCheckNew:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable;
+ (void)writeFetchMore:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable;

+ (void)trimArrayAndWrite:(NSString *)path messages:(NSMutableArray *)messages more:(BOOL)olderAvailable;
+ (NSString *)niceDate:(NSDate *)date;
+ (NSDate *)loadFeedDate:(NSString *)url;
+ (NSString *)feedCacheUniqueID:(NSString *)url;
+ (NSMutableDictionary *)updateLastReplyIds:(NSString *)feed messages:(NSMutableArray *)messages;

+ (void)deleteOldMessages:(NSString *)feed limit:(BOOL)limit;
+ (void)writeNewMessages:(NSString *)feed messages:(NSMutableArray *)messages lookup:(NSMutableDictionary *)lookup;
+ (BOOL)createOrUpdateMetaData:(NSString *)feed updateOlderAvailable:(NSString *)older;

@end
