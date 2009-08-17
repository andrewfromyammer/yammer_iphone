//
//  APIGateway.h
//  Yammer
//
//  Created by aa on 1/29/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIGateway : NSObject {

}

+ (NSMutableDictionary *)usersCurrent:(NSString *)style;
+ (NSMutableArray *)homeTabs;
+ (NSMutableDictionary *)pushSettings;
+ (NSMutableArray *)users:(int)page style:(NSString *)style;
+ (NSMutableDictionary *)userById:(NSString *)theUserId;

+ (NSMutableDictionary *)messages:(NSMutableDictionary *)feed olderThan:(NSNumber *)olderThan style:(NSString *)style;
+ (NSMutableDictionary *)messages:(NSMutableDictionary *)feed newerThan:(NSNumber *)newerThan style:(NSString *)style;
+ (NSMutableDictionary *)messages:(NSMutableDictionary *)feed olderThan:(NSNumber *)olderThan newerThan:(NSNumber *)newerThan style:(NSString *)style;

+ (BOOL)createMessage:(NSString *)body repliedToId:(NSNumber *)repliedToId 
              groupId:(NSNumber *)groupId
                imageData:(NSData *)imageData;  
+ (BOOL)followingUser:(NSString *)theUserId;
+ (BOOL)removeFollow:(NSString *)theUserId;
+ (BOOL)addFollow:(NSString *)theUserId;
+ (BOOL)sendPushToken:(NSString *)token;
+ (BOOL)updatePushProtocol:(NSString *)protocol theId:(NSNumber *)theId;
+ (BOOL)updatePushSetting:(NSString *)feed_key status:(NSString *)statusValue theId:(NSNumber *)theId;

@end
