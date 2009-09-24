
#import <Foundation/Foundation.h>
#import "FeedDictionary.h"

@interface APIGateway : NSObject {

}

+ (NSMutableDictionary *)usersCurrent:(NSString *)style;
+ (NSMutableArray *)homeTabs;
+ (NSMutableDictionary *)pushSettings;
+ (NSMutableArray *)users:(int)page style:(NSString *)style;
+ (NSMutableDictionary *)userById:(NSString *)theUserId;

+ (NSMutableDictionary *)messages:(FeedDictionary *)feed olderThan:(NSNumber *)olderThan style:(NSString *)style;
+ (NSMutableDictionary *)messages:(FeedDictionary *)feed newerThan:(NSNumber *)newerThan style:(NSString *)style;
+ (NSMutableDictionary *)messages:(FeedDictionary *)feed olderThan:(NSNumber *)olderThan newerThan:(NSNumber *)newerThan style:(NSString *)style;

+ (BOOL)createMessage:(NSString *)body repliedToId:(NSNumber *)repliedToId 
              groupId:(NSNumber *)groupId
                imageData:(NSData *)imageData;  
+ (BOOL)followingUser:(NSString *)theUserId;
+ (BOOL)removeFollow:(NSString *)theUserId;
+ (BOOL)addFollow:(NSString *)theUserId;
+ (BOOL)sendPushToken:(NSString *)token;
+ (BOOL)updatePushField:(NSString *)field value:(NSString *)value theId:(NSNumber *)theId;
+ (BOOL)updatePushSetting:(NSString *)feed_key status:(NSString *)statusValue theId:(NSNumber *)theId;

@end
