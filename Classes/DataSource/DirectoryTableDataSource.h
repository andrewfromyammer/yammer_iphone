//
//  FeedsTableDataSource.h
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DirectoryTableDataSource : NSObject <UITableViewDataSource> {
  NSMutableArray *users;
  int lastSize;
  int page;
}

@property (nonatomic,retain) NSMutableArray *users;
@property int lastSize;
@property int page;

- (id)initWithArray:(NSMutableArray *)array;
+ (DirectoryTableDataSource *)getUsers;

- (NSMutableDictionary *)getUser:(int)index;
- (void)handleUsers:(NSMutableArray *)array;

@end
