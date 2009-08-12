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
#import "SpinnerCell.h"

@implementation DirectoryTableDataSource

@synthesize users;
@synthesize lastSize;
@synthesize page;

+ (DirectoryTableDataSource *)getUsers {
  NSMutableArray *array = [APIGateway users:1 style:nil];
  if (array)
    return [[DirectoryTableDataSource alloc] initWithArray:array]; 
  return [[DirectoryTableDataSource alloc] initWithArray:[NSMutableArray array]];
}

- (id)init {
  self.page = 1;
  self.users = [NSMutableArray array];
  return self;
}

- (void)handleUsers:(NSMutableArray *)array {
 
  int i=0;
  for (; i< [array count]; i++) {
    NSMutableDictionary *dict = [array objectAtIndex:i];
    [dict setObject:[ImageCache getImageAndSave:[dict objectForKey:@"mugshot_url"] actor_id:[dict objectForKey:@"id"] type:@"user"] forKey:@"imageData"];    
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
  
  if (indexPath.section == 0) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserCell"] autorelease];
    }
    
    NSMutableDictionary *dict = [users objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    cell.imageView.image = [[UIImage alloc] initWithData:[dict objectForKey:@"imageData"]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
  } else {
    SpinnerCell *cell = (SpinnerCell *)[tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
	  if (cell == nil) {
		  cell = [[[SpinnerCell alloc] initWithFrame:CGRectZero 
                                 reuseIdentifier:@"MoreCell"
                                        spinRect:CGRectMake(60, 12, 20, 20)
                                        textRect:CGRectMake(100, 12, 200, 20)] autorelease];
    }
    
    [cell displayMore];
    [cell hideSpinner];
  	return cell;    
  }

}


- (void)dealloc {
  [users release];
  [super dealloc];
}

@end
