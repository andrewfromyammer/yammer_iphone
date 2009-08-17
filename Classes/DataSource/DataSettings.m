//
//  FeedsTableDataSource.m
//  Yammer
//
//  Created by aa on 1/28/09.
//  Copyright 2009 Yammer, Inc. All rights reserved.
//

#import "DataSettings.h"
#import "APIGateway.h"
#import "LocalStorage.h"
#import "OAuthCustom.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJSON.h"
#import "YammerAppDelegate.h"

@implementation DataSettings

@synthesize email;

- (id)init {
  self.email = @"";
  return self;
}

- (void)findEmailFromDict:(NSMutableDictionary *)dict {
  
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return 2;
  
  NSArray *array = [DEV_NETWORKS componentsSeparatedByString:@" "];
  int i=0;
  for (; i<[array count]; i++) {
    if ([email hasSuffix:[array objectAtIndex:i]])
      return 3;
  }
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"SettingsCell"] autorelease];
	}
  
  if (indexPath.section == 0) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == 0)
      cell.textLabel.text = @"Logged in as:";
    else if (indexPath.row == 1)
      cell.textLabel.text = self.email;
  } else {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Threading";
      cell.imageView.image = [UIImage imageNamed:@"threaded_mode.png"];
      cell.accessoryType = UITableViewCellAccessoryNone;
      UISwitch *switchView = [[UISwitch alloc] init];
      cell.accessoryView = switchView;
      [switchView setOn:[LocalStorage threading] animated:NO];
      [switchView addTarget:self action:@selector(switchWasChanged:) forControlEvents:UIControlEventValueChanged];
      [switchView release];
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"Push Settings";
      cell.imageView.image = [UIImage imageNamed:@"push.png"];
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"Advanced";
      cell.imageView.image = [UIImage imageNamed:@"advanced.png"];
    }
  }

	return cell;
}

- (void)switchWasChanged:(id)sender {
  UISwitch *switchView = (UISwitch *)sender;
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if ([LocalStorage getFile:SETTINGS])
    dict = [[LocalStorage getFile:SETTINGS] JSONValue];
  
  if (switchView.on)
    [dict setObject:@"on" forKey:@"threaded_mode"];
  else
    [dict setObject:@"off" forKey:@"threaded_mode"];

  [LocalStorage saveFile:SETTINGS data:[dict JSONRepresentation]];
  
  YammerAppDelegate *yam = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];
  yam.threading = switchView.on;
  
  [yam resetForNewThreadingValue];
}

- (void)dealloc {
  [super dealloc];
}

@end
