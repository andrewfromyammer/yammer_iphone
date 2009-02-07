//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedsTableDataSource.h"
#import "APIGateway.h"

@implementation FeedsTableDataSource

@synthesize feeds;

+ (FeedsTableDataSource *)getFeeds:(NSMutableDictionary *)dict {
  if (dict) {
    dict = [dict objectForKey:@"web_preferences"];
    return [[FeedsTableDataSource alloc] initWithArray:[dict objectForKey:@"home_tabs"]];
  }
  return [[FeedsTableDataSource alloc] initWithArray:[NSMutableArray array]];
}

- (id)initWithArray:(NSMutableArray *)array {
 
  self.feeds = array;
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	return [feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  NSMutableDictionary *dict = [feeds objectAtIndex:indexPath.row];
  cell.text = [dict objectForKey:@"name"];
 	
	return cell;
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
