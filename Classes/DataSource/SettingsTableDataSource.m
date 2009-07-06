//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "SettingsTableDataSource.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "OAuthCustom.h"

@implementation SettingsTableDataSource

@synthesize email;

- (id)initWithDict:(NSMutableDictionary *)dict {
  
  self.email = @"";
  
  NSMutableDictionary *contact = [dict objectForKey:@"contact"];
  NSArray *addresses = [contact objectForKey:@"email_addresses"];
  int i=0;
  for (; i< [addresses count]; i++) {
    NSDictionary *emailDict = [addresses objectAtIndex:i];
    if ([emailDict objectForKey:@"type"])
      if ([[emailDict objectForKey:@"type"] isEqualToString:@"primary"]) {
        self.email = [emailDict objectForKey:@"address"];
        break;
      }
  }
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSArray *array = [DEV_NETWORKS componentsSeparatedByString:@" "];
  int i=0;
  for (; i<[array count]; i++) {
    if ([email hasSuffix:[array objectAtIndex:i]])
      return 3;
  }
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingsCell"] autorelease];
	}
  
  if (indexPath.row == 0) {
    if (indexPath.section == 0)
      cell.textLabel.text = @"Logged in as:";
    else if (indexPath.section == 1)
      cell.textLabel.text = @"Feed for home page:";
    else if (indexPath.section == 2)
      cell.textLabel.text = @"Advanced:";
  }
  else {
    if (indexPath.section == 0)
      cell.textLabel.text = self.email;
    else if (indexPath.section == 1)
      cell.textLabel.text = [[LocalStorage getFeedInfo] objectForKey:@"name"];
    else if (indexPath.section == 2)
      cell.textLabel.text = @"Advanced Options";
  }
 	
	return cell;
}


- (void)dealloc {
  [super dealloc];
}

@end
