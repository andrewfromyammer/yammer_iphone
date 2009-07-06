//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "DirectoryTableDataSource.h"
#import "APIGateway.h"
#import "ImageCache.h"

@implementation DirectoryTableDataSource

@synthesize users;
@synthesize lastSize;
@synthesize page;

+ (DirectoryTableDataSource *)getUsers {
  NSMutableArray *array = [APIGateway users:1];
  if (array)
    return [[DirectoryTableDataSource alloc] initWithArray:array]; 
  return [[DirectoryTableDataSource alloc] initWithArray:[NSMutableArray array]];
}

- (id)initWithArray:(NSMutableArray *)array {
  
  self.page = 1;
  self.users = [NSMutableArray array];
  [self handleUsers:array];
  return self;
}

- (void)handleUsers:(NSMutableArray *)array {
 
  int i=0;
  for (; i< [array count]; i++) {
    NSMutableDictionary *dict = [array objectAtIndex:i];
    [dict setObject:[ImageCache getImageAndSave:[dict objectForKey:@"mugshot_url"] user_id:[dict objectForKey:@"id"] type:@"user"] forKey:@"imageData"];    
  }  
  self.lastSize = [array count];
  [self.users addObjectsFromArray:array];
}

- (NSMutableDictionary *)getUser:(int)index {
  return [users objectAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (lastSize == 50)
    return 2;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
  	return [users count];
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserCell"] autorelease];
	}
  
  if (indexPath.section == 0) {
    NSMutableDictionary *dict = [users objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.imageView.image = [[UIImage alloc] initWithData:[dict objectForKey:@"imageData"]];
    cell.textLabel.textColor = [UIColor blackColor];
  } else {
    cell.textLabel.text = @"                fetch more";
    cell.imageView.image = nil;
    cell.textLabel.textColor = [UIColor blueColor];
  }
  
	return cell;
}


- (void)dealloc {
  [users release];
  [super dealloc];
}

@end
