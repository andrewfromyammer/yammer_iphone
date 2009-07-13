//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "FeedsTableDataSource.h"
#import "APIGateway.h"
#import "LocalStorage.h"

@implementation FeedsTableDataSource

@synthesize feeds;
@synthesize klass;

+ (FeedsTableDataSource *)getFeeds:(NSMutableDictionary *)dict klass:(NSString *)klassName {
  if (dict) {
    dict = [dict objectForKey:@"web_preferences"];
    return [[FeedsTableDataSource alloc] initWithArray:[dict objectForKey:@"home_tabs"] klass:klassName];
  }
  return [[FeedsTableDataSource alloc] initWithArray:[NSMutableArray array] klass:klassName];
}

- (id)initWithArray:(NSMutableArray *)array klass:(NSString *)klassName {
  self.feeds = array;
  self.klass = klassName;
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"FeedCell"] autorelease];
	}
  
  NSMutableDictionary *dict = [feeds objectAtIndex:indexPath.row];
  cell.textLabel.text = [dict objectForKey:@"name"];
  cell.imageView.image = nil;
  if ([[dict objectForKey:@"private"] intValue] == 1)
    cell.imageView.image = [UIImage imageNamed:@"lock.png"];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  if ([klass isEqualToString:@"FeedViewController"])
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  else if ([klass isEqualToString:@"SettingsChooseFeed"]) {
    NSString *currentURL = [[LocalStorage getFeedInfo] objectForKey:@"url"];
    
    NSString *rowURL = [[feeds objectAtIndex:indexPath.row] objectForKey:@"url"];
    
    if ([rowURL isEqualToString:currentURL])
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  else if ([klass isEqualToString:@"SettingsPush"]) {
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    [switchView setTag:[indexPath row]];
    [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
    [switchView release];   
  }
  
	return cell;
}

- (void)switchWasChanged:(id)sender {
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Switch Changed."
                        message:@"Wefwef"
                        delegate:nil
                        cancelButtonTitle:@"Thanks!"
                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (NSMutableDictionary *)feedAtIndex:(int)index {
  return [feeds objectAtIndex:index];
}

- (void)dealloc {
  [feeds release];
  [super dealloc];
}

@end
