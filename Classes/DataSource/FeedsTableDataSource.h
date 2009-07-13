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
  NSString *klass;
}

@property (nonatomic,retain) NSMutableArray *feeds;
@property (nonatomic,retain) NSString *klass;

- (id)initWithArray:(NSMutableArray *)array klass:(NSString *)klassName;
+ (FeedsTableDataSource *)getFeeds:(NSMutableDictionary *)dict klass:(NSString *)klassName;

- (NSMutableDictionary *)feedAtIndex:(int)index;


@end
