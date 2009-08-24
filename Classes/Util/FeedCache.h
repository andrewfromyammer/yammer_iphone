//
//  ImageCache.h
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedMetaData.h"

static int MAX_FEED_CACHE = 1000;


@interface FeedCache : NSObject {

}

+ (BOOL)writeCheckNew:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply;
+ (void)writeFetchMore:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply;

+ (NSString *)niceDate:(NSDate *)date;
+ (NSDate *)loadFeedDate:(NSMutableDictionary *)dict;
+ (FeedMetaData *)loadFeedMeta:(NSString *)feed;
+ (NSString *)feedCacheUniqueID:(NSMutableDictionary *)feed;
+ (NSMutableDictionary *)updateLastReplyIds:(NSString *)feed messages:(NSMutableArray *)messages;

+ (void)deleteOldMessages:(NSString *)feed limit:(BOOL)limit useLatestReply:(BOOL)useLatestReply;
+ (void)writeNewMessages:(NSString *)feed messages:(NSMutableArray *)messages lookup:(NSMutableDictionary *)lookup;
+ (BOOL)createOrUpdateMetaData:(NSString *)feed lastMessageId:(NSNumber *)lastMessageId;
+ (void)purgeOldFeeds;
+ (NSDate *)dateFromText:(NSString *)text;

@end
