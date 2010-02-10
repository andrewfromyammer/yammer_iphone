
#import <Foundation/Foundation.h>
#import "FeedDictionary.h"

@interface APIGateway : NSObject {

}

+ (NSString*)push_file;
+ (NSString*)push_file_with_id:(long)theid;

+ (NSString*)user_file;
+ (NSString*)user_file_with_id:(long)theid;

+ (NSMutableDictionary*)usersCurrent:(NSString*)style;
+ (NSMutableArray*)homeTabs;
+ (NSMutableDictionary *)pushSettings:(NSString*)style;
+ (NSMutableArray*)users:(int)page style:(NSString*)style;
+ (NSMutableDictionary*)userById:(NSString*)theUserId;

+ (NSMutableDictionary*)autocomplete:(NSString*)prefix;

+ (NSMutableDictionary*)messages:(FeedDictionary*)feed olderThan:(NSNumber*)olderThan style:(NSString*)style;
+ (NSMutableDictionary*)messages:(FeedDictionary*)feed newerThan:(NSNumber*)newerThan style:(NSString*)style;
+ (NSMutableDictionary*)messages:(FeedDictionary*)feed olderThan:(NSNumber*)olderThan newerThan:(NSNumber*)newerThan style:(NSString*)style;

+ (NSMutableArray*)getTokens;
+ (NSMutableArray*)networksCurrent:(NSString*)style;
+ (NSMutableArray*)networksCurrentWithTimeout;

+ (BOOL)createMessage:(NSString*)body repliedToId:(NSNumber*)repliedToId 
              groupId:(NSNumber*)groupId
                imageData:(NSData*)imageData;  
+ (BOOL)followingUser:(NSString*)theUserId;
+ (BOOL)removeFollow:(NSString*)theUserId;
+ (BOOL)addFollow:(NSString*)theUserId;
+ (BOOL)sendPushToken:(NSString*)token;
+ (BOOL)updatePushField:(NSString *)field value:(NSString *)value theId:(NSNumber *)theId pushSettings:(NSMutableDictionary*)pushSettings;
+ (BOOL)updatePushSetting:(NSString*)feed_key status:(NSString*)statusValue theId:(NSNumber*)theId pushSettings:(NSMutableDictionary*)pushSettings;
+ (BOOL)updatePushSettingsInBulk:(NSNumber *)theId pushSettings:(NSMutableDictionary*)pushSettings;
+ (BOOL)likeMessage:(NSNumber*)message_id;
+ (BOOL)unlikeMessage:(NSNumber*)message_id;

@end
