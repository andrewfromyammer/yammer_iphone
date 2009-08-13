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
  BOOL fetchingMore;
  NSString *feed;
  NSFetchedResultsController *fetcher;
  BOOL showReplyCounts;
}

@property (nonatomic,retain) NSMutableArray *messages;
@property BOOL olderAvailable;
@property BOOL fetchingMore;
@property BOOL showReplyCounts;
@property (nonatomic,retain) NSString *feed;
@property (nonatomic,retain) NSFetchedResultsController *fetcher;

- (id)initWithEmpty;
- (id)initWithFeed:(NSMutableDictionary *)theFeed;
- (void)fetch;
- (void)proccesMessages:(NSMutableDictionary *)dict checkNew:(BOOL)checkNew;


@end
