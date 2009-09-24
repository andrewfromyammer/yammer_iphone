#import <Foundation/Foundation.h>
#import "FeedMetaData.h"
#import "FeedDictionary.h"

@interface FeedCache : NSObject {

}
+ (int)maxSize;

+ (BOOL)writeCheckNew:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply;
+ (void)writeFetchMore:(NSString *)feed messages:(NSMutableArray *)messages more:(BOOL)olderAvailable useLatestReply:(BOOL)useLatestReply;

+ (NSString *)niceDate:(NSDate *)date;
+ (NSDate *)loadFeedDate:(FeedDictionary *)dict;
+ (FeedMetaData *)loadFeedMeta:(NSString *)feed;
+ (NSString *)feedCacheUniqueID:(FeedDictionary *)feed;
+ (NSMutableDictionary *)updateLastReplyIds:(NSString *)feed messages:(NSMutableArray *)messages;

+ (void)deleteOldMessages:(NSString *)feed limit:(BOOL)limit useLatestReply:(BOOL)useLatestReply;
+ (void)writeNewMessages:(NSString *)feed messages:(NSMutableArray *)messages lookup:(NSMutableDictionary *)lookup;
+ (BOOL)createOrUpdateMetaData:(NSString *)feed lastMessageId:(NSNumber *)lastMessageId;
+ (void)purgeOldFeeds;
+ (NSDate *)dateFromText:(NSString *)text;

@end
