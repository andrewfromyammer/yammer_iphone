//
//  DirectoryUserDataSource.m
//  Yammer
//
//  Created by aa on 1/30/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "DirectoryUserDataSource.h"

@implementation DirectoryUserDataSource

@synthesize userData;

- (id)initWithDict:(NSMutableDictionary *)dict {
  self.userData = [NSMutableDictionary dictionary];

  NSMutableDictionary *contact = [dict objectForKey:@"contact"];
  NSMutableArray *email_addresses = [contact objectForKey:@"email_addresses"];
  NSMutableArray *phone_numbers = [contact objectForKey:@"phone_numbers"];
  
  int i=0;
  for (; i<[email_addresses count]; i++) {
    NSMutableDictionary *email = [email_addresses objectAtIndex:i];
    [userData setObject:[email objectForKey:@"address"] forKey:[NSString stringWithFormat:@"Email %@", [email objectForKey:@"type"]]];    
  }

  i=0;
  for (; i<[phone_numbers count]; i++) {
    NSMutableDictionary *phone = [phone_numbers objectAtIndex:i];    
    [userData setObject:[phone objectForKey:@"number"] forKey:[NSString stringWithFormat:@"Phone %@", [phone objectForKey:@"type"]]];    
  }
  
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [userData count];
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDataCell"];
  
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserDataCell"] autorelease];
	}
  
  NSArray *keys = [userData allKeys];
  
  if (indexPath.row == 0)
    cell.textLabel.text = [keys objectAtIndex:indexPath.section];
  else
    cell.textLabel.text = [userData objectForKey:[keys objectAtIndex:indexPath.section]];
 	
	return cell;
}


- (void)dealloc {
  [userData release];
  [super dealloc];
}


@end
