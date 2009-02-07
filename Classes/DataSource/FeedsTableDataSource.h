//
//  FeedsTableDataSource.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedsTableDataSource.h"

@interface FeedsTableDataSource : NSObject <UITableViewDataSource> {
  NSMutableArray *feeds;
}

@property (nonatomic,retain) NSMutableArray *feeds;

- (id)initWithArray:(NSMutableArray *)array;
+ (FeedsTableDataSource *)getFeeds:(NSMutableDictionary *)dict;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
