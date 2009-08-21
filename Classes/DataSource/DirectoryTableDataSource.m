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
#import "LocalStorage.h"

@implementation DirectoryTableDataSource

@synthesize users;
@synthesize lastSize;
@synthesize page;
@synthesize nameField;

+ (DirectoryTableDataSource *)getUsers {
  NSMutableArray *array = [APIGateway users:1 style:nil];
  if (array)
    return [[DirectoryTableDataSource alloc] initWithArray:array]; 
  return [[DirectoryTableDataSource alloc] initWithArray:[NSMutableArray array]];
}

- (id)init {
  self.page = 1;
  self.users = [NSMutableArray array];
  self.nameField = [LocalStorage getNameField];
  return self;
}

- (void)handleUsers:(NSMutableArray *)array {
 
  int i=0;
  for (; i< [array count]; i++) {
    NSMutableDictionary *dict = [array objectAtIndex:i];

    if ([ImageCache getImage:[[dict objectForKey:@"id"] description] type:@"user"])
      continue;
    
    [NSThread detachNewThreadSelector:@selector(loadThatImage:) toTarget:self withObject:dict];
  }  
  self.lastSize = [array count];
  [self.users addObjectsFromArray:array];
}

- (void)loadThatImage:(NSMutableDictionary *)dict {
  NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
  @synchronized ([UIApplication sharedApplication]) {
    [ImageCache getImageAndSave:[dict objectForKey:@"mugshot_url"] actor_id:[dict objectForKey:@"id"] type:@"user"];
  }
  [autoreleasepool release];
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
    
    if (cell == nil)
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserCell"] autorelease];
    
    
    NSMutableDictionary *dict = [users objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:nameField];
    
    cell.imageView.image = nil;
    NSData *imageData = [ImageCache getImage:[[dict objectForKey:@"id"] description] type:@"user"];
    if (imageData)
      cell.imageView.image = [[UIImage alloc] initWithData:imageData];
    
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
  [nameField release];
  [super dealloc];
}

@end
