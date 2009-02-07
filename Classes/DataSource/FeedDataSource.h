//
//  FeedsTableDataSource.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedDataSource.h"

@interface FeedDataSource : NSObject <UITableViewDataSource> {
  NSMutableArray *messages;
  BOOL olderAvailable;
}

@property (nonatomic,retain) NSMutableArray *messages;
@property BOOL olderAvailable;

- (id)initWithDict:(NSMutableDictionary *)dict;
+ (FeedDataSource *)getMessages:(NSMutableDictionary *)feed;
- (void)proccesMessages:(NSMutableDictionary *)dict;


@end
